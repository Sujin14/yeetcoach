import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/services/call_native_service.dart';
import 'package:yeetcoach/core/services/launch_coordinator.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_party.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_type.dart';

/// Hands every native accept to [LaunchCoordinator] (warm or cold start).
Future<void> handleAcceptedCall(AcceptedCall call) async {
  LaunchCoordinator.instance.offerCall(call);
}

/// Opens the Flutter call screen after the coach accepts on the native UI.
Future<void> openAcceptedCall(AcceptedCall call) async {
  logDebug('[YeetCall] openAcceptedCall: ${call.callId}');
  if (call.callId.startsWith('test_')) {
    await CallNativeService.clearLockScreenFlags();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(CallNativeService.prefsCallSetupTestPassed, true);
    if (Get.currentRoute == AppRoutes.callSetup) {
      await Get.offNamed(AppRoutes.callSetup);
    } else {
      Get.toNamed(AppRoutes.callSetup);
    }
    return;
  }

  if (Get.currentRoute == AppRoutes.call || Get.currentRoute == AppRoutes.incomingCall) {
    logDebug('[YeetCall] openAcceptedCall: already in a call — ignoring ${call.callId}');
    await CallNativeService.clearLockScreenFlags();
    return;
  }

  final type = CallType.values.firstWhere(
    (value) => value.name == call.callType,
    orElse: () => CallType.audio,
  );
  final party = CallParty(
    uid: call.callerId,
    name: call.callerName.isNotEmpty ? call.callerName : 'Client',
    photoUrl: call.callerPhotoUrl,
  );

  Get.toNamed(AppRoutes.incomingCall, arguments: {
    'callId': call.callId,
    'type': type,
    'party': party,
    'autoAnswer': true,
  });
}
