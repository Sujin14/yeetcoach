import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';

/// Snapshot of Android call-permission readiness from native [CallReadiness].
class CallReadiness {
  final bool notificationsEnabled;
  final bool channelOk;
  final bool fullScreenOk;
  final bool batteryOk;
  final bool needsOemSetup;
  final String manufacturer;
  final String oemInstructions;

  const CallReadiness({
    required this.notificationsEnabled,
    required this.channelOk,
    required this.fullScreenOk,
    required this.batteryOk,
    required this.needsOemSetup,
    required this.manufacturer,
    required this.oemInstructions,
  });

  factory CallReadiness.fromMap(Map<Object?, Object?> map) {
    bool asBool(Object? v) => v == true;
    return CallReadiness(
      notificationsEnabled: asBool(map['notificationsEnabled']),
      channelOk: asBool(map['channelOk']),
      fullScreenOk: asBool(map['fullScreenOk']),
      batteryOk: asBool(map['batteryOk']),
      needsOemSetup: asBool(map['needsOemSetup']),
      manufacturer: map['manufacturer']?.toString() ?? '',
      oemInstructions: map['oemInstructions']?.toString() ?? '',
    );
  }

  bool get coreOk =>
      notificationsEnabled && channelOk && fullScreenOk && batteryOk;
}

/// Payload from a native Accept (warm or cold start).
class AcceptedCall {
  final String callId;
  final String callerId;
  final String callerName;
  final String callerPhotoUrl;
  final String callType;

  const AcceptedCall({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.callerPhotoUrl,
    required this.callType,
  });

  factory AcceptedCall.fromMap(Map<Object?, Object?> map) {
    return AcceptedCall(
      callId: map['callId']?.toString() ?? '',
      callerId: map['callerId']?.toString() ?? '',
      callerName: map['callerName']?.toString() ?? '',
      callerPhotoUrl: map['callerPhotoUrl']?.toString() ?? '',
      callType: map['callType']?.toString() ?? '',
    );
  }
}

/// Dart bridge to YeetCoach's native incoming-call UI
/// ([CallNotificationManager] / [MainActivity] MethodChannel).
class CallNativeService {
  static const MethodChannel _call = MethodChannel('com.sujin.yeetcoach/incoming_call');

  static const String prefsCallSetupCompleted = 'call_setup_completed';
  static const String prefsCallSetupTestPassed = 'call_setup_test_passed';

  /// Set when a cold-start accept is consumed, or whenever [handleAcceptedCall] runs.
  static bool launchedForCall = false;

  /// True after splash (or login/onboarding) has navigated to a lasting route.
  static bool homeReady = false;

  /// Accept that arrived while splash was still showing; drained when splash leaves.
  static final ValueNotifier<AcceptedCall?> coldStartCall = ValueNotifier(null);

  static Future<AcceptedCall?> consumePendingAcceptedCall() async {
    try {
      final raw = await _call.invokeMethod<Map<Object?, Object?>>('consumePendingAcceptedCall');
      if (raw == null) {
        logDebug('[YeetCall] consumePendingAcceptedCall: null');
        return null;
      }
      final accepted = AcceptedCall.fromMap(raw);
      if (accepted.callId.isEmpty) {
        logDebug('[YeetCall] consumePendingAcceptedCall: empty callId');
        return null;
      }
      logDebug('[YeetCall] consumePendingAcceptedCall: ${accepted.callId}');
      return accepted;
    } catch (e) {
      logDebug('[YeetCall] consumePendingAcceptedCall error: $e');
      return null;
    }
  }

  static Future<void> dismissIncomingCall(String? callId) async {
    try {
      await _call.invokeMethod<void>('dismissIncomingCall', callId);
      logDebug('[YeetCall] dismissIncomingCall: $callId');
    } catch (e) {
      logDebug('[YeetCall] dismissIncomingCall error: $e');
    }
  }

  static Future<String?> getActiveRingingCallId() async {
    try {
      final id = await _call.invokeMethod<String>('getActiveRingingCallId');
      logDebug('[YeetCall] getActiveRingingCallId: $id');
      return id;
    } catch (e) {
      logDebug('[YeetCall] getActiveRingingCallId error: $e');
      return null;
    }
  }

  static Future<void> clearLockScreenFlags() async {
    try {
      await _call.invokeMethod<void>('clearLockScreenFlags');
      logDebug('[YeetCall] clearLockScreenFlags');
    } catch (e) {
      logDebug('[YeetCall] clearLockScreenFlags error: $e');
    }
  }

  /// Warm-path accept from native. Always claims the payload via
  /// [consumePendingAcceptedCall] so accepts are never handled twice.
  static void setOnCallAccepted(Future<void> Function(AcceptedCall call) handler) {
    _call.setMethodCallHandler((call) async {
      if (call.method != 'callAccepted') return;
      final pending = await consumePendingAcceptedCall();
      if (pending == null) {
        logDebug('[YeetCall] callAccepted with no pending id — ignored');
        return;
      }
      logDebug('[YeetCall] callAccepted handler for ${pending.callId}');
      await handler(pending);
    });
  }

  static Future<CallReadiness?> getCallReadiness() async {
    try {
      final raw = await _call.invokeMethod<Map<Object?, Object?>>('getCallReadiness');
      if (raw == null) {
        logDebug('[YeetCall] getCallReadiness: null');
        return null;
      }
      final readiness = CallReadiness.fromMap(raw);
      logDebug(
        '[YeetCall] getCallReadiness: coreOk=${readiness.coreOk} '
        'oem=${readiness.needsOemSetup}',
      );
      return readiness;
    } catch (e) {
      logDebug('[YeetCall] getCallReadiness error: $e');
      return null;
    }
  }

  static Future<bool> openCallSetting(String which) async {
    try {
      final opened = await _call.invokeMethod<bool>('openCallSetting', which);
      logDebug('[YeetCall] openCallSetting($which): $opened');
      return opened ?? false;
    } catch (e) {
      logDebug('[YeetCall] openCallSetting($which) error: $e');
      return false;
    }
  }

  static Future<void> scheduleTestCall({int delayMs = 10000}) async {
    try {
      await _call.invokeMethod<void>('scheduleTestCall', delayMs);
      logDebug('[YeetCall] scheduleTestCall delayMs=$delayMs');
    } catch (e) {
      logDebug('[YeetCall] scheduleTestCall error: $e');
    }
  }

  /// Firestore fallback when FCM is delayed or missing while the app is open.
  static Future<void> showIncomingCall(Map<String, String> data) async {
    try {
      await _call.invokeMethod<void>('showIncomingCall', data);
      logDebug('[YeetCall] showIncomingCall: ${data['callId']}');
    } catch (e) {
      logDebug('[YeetCall] showIncomingCall error: $e');
    }
  }
}
