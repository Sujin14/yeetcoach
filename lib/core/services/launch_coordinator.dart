import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/services/call_accept_handler.dart';
import 'package:yeetcoach/core/services/call_native_service.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';

/// Serialises splash exit and cold-start call accepts so they never race the navigator.
class LaunchCoordinator {
  LaunchCoordinator._();
  static final instance = LaunchCoordinator._();

  AcceptedCall? _pendingCall;
  bool _homeReady = false;
  bool _leavingSplash = false;
  bool launchedForCall = false;
  final Set<String> _openedCallIds = {};

  /// Splash registers this to leave early when a call is offered before home is ready.
  VoidCallback? onCallPending;

  bool get homeReady => _homeReady;

  /// Single entry point for every accepted call (native push or splash consume).
  void offerCall(AcceptedCall call) {
    logDebug('[YeetCall] launch offerCall: ${call.callId}');
    if (_openedCallIds.contains(call.callId)) {
      logDebug('[YeetCall] launch offerCall: already opened ${call.callId} — ignore');
      return;
    }
    launchedForCall = true;
    if (_homeReady) {
      _openedCallIds.add(call.callId);
      logDebug('[YeetCall] launch offerCall: home ready — opening ${call.callId}');
      _runAfterFrame('openCall', () => openAcceptedCall(call));
      return;
    }
    _pendingCall = call;
    logDebug('[YeetCall] launch offerCall: parked pending ${call.callId}');
    onCallPending?.call();
  }

  /// Single, idempotent way to leave splash.
  void leaveSplash({
    required String homeRoute,
    required bool signedIn,
    VoidCallback? afterNavigation,
  }) {
    if (_leavingSplash) {
      logDebug('[YeetCall] launch leaveSplash: already leaving — ignore');
      return;
    }
    _leavingSplash = true;
    logDebug(
      '[YeetCall] launch leaveSplash: route=$homeRoute signedIn=$signedIn '
      'pending=${_pendingCall?.callId}',
    );
    _runAfterFrame('leaveSplash', () async {
      Get.offAllNamed(homeRoute);
      _homeReady = true;
      logDebug('[YeetCall] launch leaveSplash: homeReady=true');

      final pending = _pendingCall;
      if (signedIn && pending != null) {
        _pendingCall = null;
        _openedCallIds.add(pending.callId);
        logDebug('[YeetCall] launch leaveSplash: opening pending ${pending.callId}');
        await openAcceptedCall(pending);
        return;
      }

      if (!signedIn && pending != null) {
        logDebug('[YeetCall] launch leaveSplash: dropping pending ${pending.callId} (not signed in)');
        _pendingCall = null;
      }
      afterNavigation?.call();
    });
  }

  /// For routes that reach home without splash (e.g. after login).
  void markHomeReady() {
    _homeReady = true;
    logDebug('[YeetCall] launch markHomeReady pending=${_pendingCall?.callId}');
    final pending = _pendingCall;
    if (pending == null) return;
    _pendingCall = null;
    if (_openedCallIds.contains(pending.callId)) {
      logDebug('[YeetCall] launch markHomeReady: already opened ${pending.callId}');
      return;
    }
    launchedForCall = true;
    _openedCallIds.add(pending.callId);
    _runAfterFrame('openCallAfterMarkHomeReady', () => openAcceptedCall(pending));
  }

  void _runAfterFrame(String label, FutureOr<void> Function() action) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        await action();
      } catch (e, s) {
        logDebug('[YeetCall] launch $label failed: $e\n$s');
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }
}
