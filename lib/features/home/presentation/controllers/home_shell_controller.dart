import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/services/call_native_service.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/features/calls/data/repositories/call_repository.dart';
import 'package:yeetcoach/features/calls/domain/entities/incoming_ring.dart';
import 'package:yeetcoach/features/calls/domain/repositories/i_call_repository.dart';

/// Order matches the bottom navigation bar.
enum HomeTab { home, clients, chats, challenges }

class HomeShellController extends GetxController {
  final ICallRepository _calls;

  HomeShellController({ICallRepository? calls}) : _calls = calls ?? CallRepository();

  final Rx<HomeTab> currentTab = HomeTab.home.obs;

  StreamSubscription<IncomingRing?>? _incomingCalls;
  final Set<String> _seenRingingIds = {};
  static var _callSetupPromptedThisLaunch = false;

  @override
  void onInit() {
    super.onInit();
    // Lets a push notification open /home on a specific tab.
    if (Get.arguments case {'tab': HomeTab tab}) currentTab.value = tab;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _watchIncomingCalls(uid);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_maybePromptCallSetup());
    });
  }

  /// Once per launch on Android: open call setup if incomplete or core permissions fail.
  Future<void> _maybePromptCallSetup() async {
    if (_callSetupPromptedThisLaunch) return;
    if (kIsWeb || !Platform.isAndroid) return;
    if (CallNativeService.launchedForCall) return;
    final route = Get.currentRoute;
    if (route == AppRoutes.call || route == AppRoutes.incomingCall) return;
    _callSetupPromptedThisLaunch = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(CallNativeService.prefsCallSetupCompleted) ?? false;
      final readiness = await CallNativeService.getCallReadiness();
      if (completed && (readiness?.coreOk ?? false)) return;
      if (CallNativeService.launchedForCall) return;
      final after = Get.currentRoute;
      if (after == AppRoutes.call || after == AppRoutes.incomingCall) return;
      Get.toNamed(AppRoutes.callSetup);
    } catch (e) {
      logDebug('HomeShellController: call setup prompt failed: $e');
    }
  }

  /// Native owns the ringing UI. Firestore is the fallback when FCM is late,
  /// and dismisses the native UI when the call stops ringing.
  void _watchIncomingCalls(String uid) {
    _incomingCalls = _calls.watchIncomingRing(uid).listen(
      (ring) {
        if (ring == null) {
          for (final id in _seenRingingIds) {
            unawaited(CallNativeService.dismissIncomingCall(id));
          }
          _seenRingingIds.clear();
          return;
        }

        final next = {ring.callId};
        for (final id in _seenRingingIds.difference(next)) {
          unawaited(CallNativeService.dismissIncomingCall(id));
        }
        if (!_seenRingingIds.contains(ring.callId)) {
          unawaited(
            CallNativeService.showIncomingCall({
              'callId': ring.callId,
              'callerId': ring.caller.uid,
              'callerName': ring.caller.name,
              'callerPhotoUrl': ring.caller.photoUrl,
              'callType': ring.type.name,
            }),
          );
        }
        _seenRingingIds
          ..clear()
          ..addAll(next);
      },
      onError: (Object error) => logDebug('HomeShellController: incoming call stream failed: $error'),
    );
  }

  @override
  void onClose() {
    _incomingCalls?.cancel();
    super.onClose();
  }

  void selectTab(HomeTab tab) => currentTab.value = tab;

  /// Shows [tab], closing any screens pushed on top of /home first.
  static void open(HomeTab tab) {
    if (!Get.isRegistered<HomeShellController>()) {
      Get.offAllNamed(AppRoutes.home, arguments: {'tab': tab});
      return;
    }
    if (Get.currentRoute != AppRoutes.home) {
      Get.until((route) => route.settings.name == AppRoutes.home);
    }
    Get.find<HomeShellController>().selectTab(tab);
  }
}
