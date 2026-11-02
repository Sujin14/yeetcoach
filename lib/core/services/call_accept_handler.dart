import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/services/call_native_service.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_party.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_type.dart';

/// Opens the Flutter call screen after the coach accepts on the native UI.
Future<void> handleAcceptedCall(AcceptedCall call) async {
  logDebug('[YeetCall] handleAcceptedCall: ${call.callId}');
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

  if (!CallNativeService.homeReady) {
    CallNativeService.launchedForCall = true;
    CallNativeService.coldStartCall.value = call;
    logDebug(
      '[YeetCall] handleAcceptedCall: splash still showing — handing off ${call.callId}',
    );
    return;
  }

  CallNativeService.launchedForCall = true;

  if (Get.currentRoute == AppRoutes.call || Get.currentRoute == AppRoutes.incomingCall) {
    logDebug('[YeetCall] handleAcceptedCall: already in a call — ignoring ${call.callId}');
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
