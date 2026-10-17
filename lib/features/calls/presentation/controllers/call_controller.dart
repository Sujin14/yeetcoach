import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import '../../data/datasources/call_exception.dart';
import '../../data/datasources/call_media_session.dart';
import '../../domain/entities/call_party.dart';
import '../../domain/entities/call_session.dart';
import '../../domain/entities/call_status.dart';
import '../../domain/entities/call_type.dart';
import '../../domain/repositories/i_call_repository.dart';

enum CallPhase { incoming, ringing, connecting, connected, reconnecting, finished }

/// One call with a client, outgoing or incoming. Loaded from route arguments:
/// {'callId': String, 'type': CallType, 'party': CallParty}, where party is the client.
class CallController extends GetxController {
  /// Matches YeetFit's ring timeout on both the caller and receiver side.
  static const Duration ringTimeout = Duration(seconds: 30);

  /// How long the final status ("Call declined", ...) stays up before the screen closes.
  static const Duration _finishedDisplayTime = Duration(milliseconds: 1500);

  final ICallRepository _repository;

  /// True when the client called the coach: the call starts in [CallPhase.incoming]
  /// and media is joined only once the coach answers.
  final bool isIncoming;

  CallController(this._repository, {this.isIncoming = false});

  late final String callId;
  late final CallType type;
  late final CallParty party;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  final CallMediaSession _media = CallMediaSession();

  final Rx<CallPhase> phase = CallPhase.ringing.obs;
  final RxnString finishedMessage = RxnString();
  final Rxn<DateTime> connectedAt = Rxn<DateTime>();
  final RxBool hasRemoteStream = false.obs;
  final RxBool isMuted = false.obs;
  final RxBool isCameraOff = false.obs;
  final RxBool isSpeakerOn = false.obs;

  /// True while an incoming call is joining the room and being marked active.
  final RxBool isAnswering = false.obs;

  late final Future<void> _renderersReady;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _ringTimer;
  String? _channelId;
  bool _mediaStarted = false;
  bool _leaving = false;

  bool get isVideo => type.isVideo;

  String get _routeName => isIncoming ? AppRoutes.incomingCall : AppRoutes.call;

  @override
  void onInit() {
    super.onInit();
    phase.value = isIncoming ? CallPhase.incoming : CallPhase.ringing;
    final args = Get.arguments;
    if (args case {'callId': String id, 'type': CallType callType, 'party': CallParty callParty}
        when id.isNotEmpty) {
      callId = id;
      type = callType;
      party = callParty;
    } else {
      logDebug('CallController: invalid arguments: $args');
      callId = '';
      type = CallType.audio;
      party = const CallParty(uid: '', name: '');
      _renderersReady = Future.value();
      _finish('Call could not start');
      return;
    }

    isSpeakerOn.value = isVideo;
    _renderersReady = Future.wait([localRenderer.initialize(), remoteRenderer.initialize()]);
    // Incoming: an unanswered call is marked missed even if the caller's app never does.
    _ringTimer = Timer(ringTimeout, _onRingTimeout);
    _subscriptions.add(
      _repository.watchCall(callId).listen(
        _onCallChanged,
        onError: (Object e) {
          logDebug('CallController: call stream error: $e');
          _endCallInBackground();
          _finish('Call failed');
        },
      ),
    );
  }

  void _onCallChanged(CallSession? call) {
    if (_leaving) return;
    if (call == null) {
      _finish('Call ended');
      return;
    }
    _channelId = call.channelId;
    switch (call.status) {
      case CallStatus.ringing:
        break;
      case CallStatus.active:
        _ringTimer?.cancel();
        connectedAt.value ??= call.startedAt ?? DateTime.now();
        if (_mediaStarted) break;
        if (isIncoming) {
          // Answered somewhere else, or a stale notification for a call already in progress.
          _finish('Call ended');
          break;
        }
        _mediaStarted = true;
        phase.value = CallPhase.connecting;
        _startMedia(call.channelId);
      case CallStatus.declined:
        _finish('Call declined');
      case CallStatus.missed:
        _finish(isIncoming ? 'Missed call' : 'No answer');
      case CallStatus.ended:
        _finish('Call ended');
    }
  }

  /// Joins the Metered room. Returns false (and closes the screen) if joining failed.
  Future<bool> _startMedia(String channelId) async {
    try {
      await _renderersReady;
      final apiKey = await _repository.getRealtimeApiKey();
      if (_leaving) return false;
      _subscriptions
        ..add(_media.remoteStreams.listen(_onRemoteStream))
        ..add(_media.reconnecting.listen(_onReconnecting));
      final local = await _media.start(apiKey: apiKey, channelId: channelId, video: isVideo);
      if (_leaving) return false;
      if (isVideo) localRenderer.srcObject = local;
      return true;
    } catch (e) {
      logDebug('CallController: joining the call failed: $e');
      if (_leaving) return false;
      // Stop the client ringing or waiting for media that won't come.
      _endCallInBackground();
      _finish(e is CallException ? e.message : 'Could not connect the call');
      return false;
    }
  }

  /// Incoming only: joins the room first, then marks the call active so the
  /// client's app stops ringing once the coach can actually be heard.
  Future<void> answer() async {
    if (!isIncoming || _leaving || _mediaStarted) return;
    _mediaStarted = true;
    isAnswering.value = true;
    _ringTimer?.cancel();
    try {
      if (!await _startMedia(_channelId ?? callId)) return;
      await _repository.acceptCall(callId);
      if (_leaving) return;
      phase.value = hasRemoteStream.value ? CallPhase.connected : CallPhase.connecting;
    } catch (e) {
      logDebug('CallController: answering the call failed: $e');
      if (_leaving) return;
      if (e is! CallException) _endCallInBackground();
      _finish(e is CallException ? e.message : 'Could not answer the call');
    } finally {
      isAnswering.value = false;
    }
  }

  /// Incoming only: declines the ringing call and closes the screen right away;
  /// the status write completes in the background.
  void decline() {
    if (!isIncoming || _leaving || isAnswering.value) return;
    _leaving = true;
    _releaseMedia();
    _declineCallInBackground();
    _closeScreen();
  }

  void _onRemoteStream(MediaStream? stream) {
    if (_leaving) return;
    // Re-bind on every event: a reconnect delivers a fresh stream object.
    remoteRenderer.srcObject = stream;
    hasRemoteStream.value = stream != null;
    // An incoming call switches to the in-call UI only once answer() has marked it active.
    if (phase.value != CallPhase.reconnecting && phase.value != CallPhase.incoming) {
      phase.value = stream != null ? CallPhase.connected : CallPhase.connecting;
    }
  }

  void _onReconnecting(bool reconnecting) {
    if (_leaving || phase.value == CallPhase.incoming) return;
    phase.value = reconnecting
        ? CallPhase.reconnecting
        : (hasRemoteStream.value ? CallPhase.connected : CallPhase.connecting);
  }

  Future<void> _onRingTimeout() async {
    try {
      await _repository.markMissed(callId);
    } on CallException {
      // Answered or ended in the meantime.
    } catch (e) {
      logDebug('CallController: marking call missed failed: $e');
    }
  }

  /// Ends the call for both sides and closes the screen right away;
  /// the status write completes in the background.
  void hangUp() {
    if (!_leaving) {
      _endCallInBackground();
      _leaving = true;
      _releaseMedia();
    }
    _closeScreen();
  }

  void toggleMute() {
    isMuted.toggle();
    _media.setMicrophoneEnabled(!isMuted.value);
  }

  void toggleCamera() {
    isCameraOff.toggle();
    _media.setCameraEnabled(!isCameraOff.value);
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn.toggle();
    await _media.setSpeakerOn(isSpeakerOn.value);
  }

  Future<void> switchCamera() => _media.switchCamera();

  /// Shows [message] briefly, then closes the screen.
  void _finish(String message) {
    if (_leaving) return;
    _leaving = true;
    finishedMessage.value = message;
    phase.value = CallPhase.finished;
    _releaseMedia();
    Future.delayed(_finishedDisplayTime, _closeScreen);
  }

  void _endCallInBackground() {
    if (callId.isEmpty) return;
    unawaited(
      _repository.endCall(callId).catchError((Object e) {
        logDebug('CallController: ending call failed: $e');
      }),
    );
  }

  void _declineCallInBackground() {
    if (callId.isEmpty) return;
    unawaited(
      _repository.declineCall(callId).catchError((Object e) {
        logDebug('CallController: declining call failed: $e');
      }),
    );
  }

  void _releaseMedia() {
    _ringTimer?.cancel();
    unawaited(_media.close());
  }

  /// popUntil rather than Get.back, which closes an open snackbar instead of the route.
  void _closeScreen() {
    Get.until((route) => route.settings.name != _routeName);
  }

  @override
  void onClose() {
    // Removed without hanging up (e.g. a notification tap reset the stack).
    if (!_leaving) {
      _leaving = true;
      if (phase.value == CallPhase.incoming && !_mediaStarted) {
        _declineCallInBackground();
      } else {
        _endCallInBackground();
      }
    }
    _ringTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    unawaited(_disposeMedia());
    super.onClose();
  }

  Future<void> _disposeMedia() async {
    await _media.close();
    for (final renderer in [localRenderer, remoteRenderer]) {
      try {
        if (renderer.textureId != null) renderer.srcObject = null;
        await renderer.dispose();
      } catch (e) {
        logDebug('CallController: disposing renderer failed: $e');
      }
    }
  }
}
