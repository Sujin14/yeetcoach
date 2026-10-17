import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeetcoach/core/constants/preference_keys.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_party.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_type.dart';
import 'package:yeetcoach/features/coach/domain/repositories/i_coach_repository.dart';
/// FCM registration, foreground display and notification-tap routing for coaches.
class PushNotificationService extends GetxService {
  PushNotificationService(
    this._coachRepository, {
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();

  /// Must match default_notification_channel_id in AndroidManifest.xml.
  static const String channelId = 'yeetcoach_default';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    channelId,
    'General',
    description: 'Client requests, messages and calls',
    importance: Importance.high,
  );

  final ICoachRepository _coachRepository;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Call once before runApp. Never throws.
  Future<void> init() async {
    try {
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permission is requested through FCM in registerCoach, not at plugin start-up.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) => _openFromPayload(response.payload),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    } catch (e) {
      logDebug('PushNotificationService: local notifications init failed: $e');
    }

    // FCM doesn't display notifications while the app is in the foreground, so they are shown locally.
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) => _openFromData(message.data));
  }

  /// Asks for notification permission, then stores this device's Firebase
  /// Installation ID on coaches/{uid}.fcmToken in the background. Only the
  /// permission prompt is awaited. Never throws.
  /// With both Settings toggles off, any stored token is removed instead.
  Future<void> registerCoach(String uid) async {
    try {
      final settings = await _messaging.requestPermission();
      final status = settings.authorizationStatus;
      if (status != AuthorizationStatus.authorized && status != AuthorizationStatus.provisional) {
        logDebug('PushNotificationService: notification permission $status');
        return;
      }
      if (!(await _readToggles()).anyOn) {
        unawaited(_removeStoredToken(uid));
        return;
      }
      unawaited(_storeCurrentRegistration(uid));
      _listenForRegistration();
    } catch (e) {
      logDebug('PushNotificationService: registerCoach failed: $e');
    }
  }

  // The four toggle methods throw only if the preference can't be saved.

  Future<void> enableNotifications() =>
      _setToggle(PreferenceKeys.notificationsEnabled, enabled: true);

  Future<void> disableNotifications() =>
      _setToggle(PreferenceKeys.notificationsEnabled, enabled: false);

  Future<void> enableCallNotifications() =>
      _setToggle(PreferenceKeys.callNotificationsEnabled, enabled: true);

  Future<void> disableCallNotifications() =>
      _setToggle(PreferenceKeys.callNotificationsEnabled, enabled: false);

  Future<void> _setToggle(String key, {required bool enabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, enabled);
    await _syncTokenIfNeeded(prefs);
  }

  /// Removes the FCM token only when both toggles are off, so no pushes reach this
  /// device; re-registers it when at least one is on.
  Future<void> _syncTokenIfNeeded(SharedPreferences prefs) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_togglesFrom(prefs).anyOn) {
      await registerCoach(uid);
      return;
    }
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    await _removeStoredToken(uid);
  }

  /// Stops this device receiving the coach's notifications. Call before sign-out, while
  /// [uid] can still write coaches/{uid}. Never throws, so logout is never blocked.
  Future<void> clearToken(String uid) async {
    // Cancelled first so a registration that completes after unregister isn't saved back.
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    try {
      await _messaging.unregister();
    } catch (e) {
      logDebug('PushNotificationService: unregister failed: $e');
    }
    await _removeStoredToken(uid);
  }

  void _listenForRegistration() {
    _tokenRefreshSubscription ??= _messaging.onRegistered.listen((installationId) async {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null && (await _readToggles()).anyOn) {
        await _saveToken(currentUid, installationId);
      }
    });
  }

  /// Never throws; registerCoach retries on the next launch while notifications stay off.
  Future<void> _removeStoredToken(String uid) async {
    try {
      await _coachRepository.updateCoachFields(uid, {'fcmToken': FieldValue.delete()});
    } catch (e) {
      logDebug('PushNotificationService: clearing fcmToken failed: $e');
    }
  }

  /// Opens the screen for a notification that launched the app from a terminated state.
  /// Call after the first frame, once the navigator exists.
  Future<void> handleLaunchTap() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _openFromData(initialMessage.data);
        return;
      }
      final launchDetails = await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _openFromPayload(launchDetails!.notificationResponse?.payload);
      }
    } catch (e) {
      logDebug('PushNotificationService: handleLaunchTap failed: $e');
    }
  }

  /// [register] does not return the id. [onRegistered] delivers the Firebase
  /// Installation ID, which is stored on coaches/{uid}.fcmToken.
  Future<void> _storeCurrentRegistration(String uid) async {
    _listenForRegistration();
    try {
      await _messaging.register();
    } catch (e) {
      logDebug('PushNotificationService: register failed for $uid: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _coachRepository.updateCoachFields(uid, {'fcmToken': token});
      logDebug('PushNotificationService: fcmToken saved for $uid');
    } catch (e) {
      logDebug('PushNotificationService: saving fcmToken failed: $e');
    }
  }

  static ({bool general, bool calls, bool anyOn}) _togglesFrom(SharedPreferences prefs) {
    final general = prefs.getBool(PreferenceKeys.notificationsEnabled) ?? true;
    final calls = prefs.getBool(PreferenceKeys.callNotificationsEnabled) ?? true;
    return (general: general, calls: calls, anyOn: general || calls);
  }

  /// The two Settings toggles; both default to on if they can't be read.
  static Future<({bool general, bool calls, bool anyOn})> _readToggles() async {
    try {
      return _togglesFrom(await SharedPreferences.getInstance());
    } catch (e) {
      logDebug('PushNotificationService: reading notification preferences failed: $e');
      return (general: true, calls: true, anyOn: true);
    }
  }

  /// Background pushes are displayed by the OS, so the per-type toggles only filter here.
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;
    if (_isOpenChat(message.data)) return;
    final callTag = _incomingCallTag(message.data);
    final toggles = await _readToggles();
    if (!(callTag != null ? toggles.calls : toggles.general)) return;
    try {
      await _localNotifications.show(
        // Calls use id 0 + tag, like the tray notification FCM posts in the background,
        // so _dismissCallNotification clears either one.
        id: callTag != null ? 0 : (message.messageId ?? '${message.sentTime}').hashCode,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            tag: callTag,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      logDebug('PushNotificationService: showing foreground notification failed: $e');
    }
  }

  void _openFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) _openFromData(decoded);
    } catch (e) {
      logDebug('PushNotificationService: bad notification payload: $e');
    }
  }

  void _openFromData(Map<String, dynamic> data) {
    if (FirebaseAuth.instance.currentUser == null) return;
    final type = data['type'];
    logDebug('PushNotificationService: notification tapped, type: $type');
    switch (type) {
      case 'new_request':
        Get.toNamed(AppRoutes.notifications);
      case 'new_message':
        // Sent by the onMessageCreated Cloud Function; the sender is the client.
        final clientUid = data['senderId'];
        if (clientUid is String && clientUid.isNotEmpty) {
          _openChat(clientUid);
        } else {
          _goHome();
        }
      case 'incoming_call':
        // Sent by the onCallCreated Cloud Function when a client calls the coach.
        _openIncomingCall(data);
    }
  }

  void _openIncomingCall(Map<String, dynamic> data) {
    final callId = data['callId'];
    final callerId = data['callerId'];
    if (callId is! String || callId.isEmpty || callerId is! String || callerId.isEmpty) {
      logDebug('PushNotificationService: incoming_call push without callId or callerId');
      return;
    }
    if (Get.currentRoute == AppRoutes.call || Get.currentRoute == AppRoutes.incomingCall) {
      logDebug('PushNotificationService: ignoring call $callId, already in a call');
      return;
    }
    unawaited(_dismissCallNotification(callId));
    final callerName = data['callerName'];
    final callerPhotoUrl = data['callerPhotoUrl'];
    // A stale tap (call already missed or ended) is closed by the call screen itself.
    Get.toNamed(AppRoutes.incomingCall, arguments: {
      'callId': callId,
      'type': CallType.values.asNameMap()[data['callType']] ?? CallType.audio,
      'party': CallParty(
        uid: callerId,
        name: callerName is String && callerName.isNotEmpty ? callerName : 'Client',
        photoUrl: callerPhotoUrl is String ? callerPhotoUrl : '',
      ),
    });
  }

  /// Matches the Android tag onCallCreated puts on the call push.
  static String? _incomingCallTag(Map<String, dynamic> data) {
    final callId = data['callId'];
    return data['type'] == 'incoming_call' && callId is String && callId.isNotEmpty
        ? 'call_$callId'
        : null;
  }

  Future<void> _dismissCallNotification(String callId) async {
    try {
      await _localNotifications.cancel(id: 0, tag: 'call_$callId');
    } catch (e) {
      logDebug('PushNotificationService: dismissing call notification failed: $e');
    }
  }

  /// True for a new_message push from the client whose chat is already on screen.
  bool _isOpenChat(Map<String, dynamic> data) {
    if (data['type'] != 'new_message' || Get.currentRoute != AppRoutes.chat) return false;
    return switch (Get.arguments) {
      {'clientUid': String uid} => uid == data['senderId'],
      _ => false,
    };
  }

  void _openChat(String clientUid) {
    final arguments = {'clientUid': clientUid};
    if (Get.currentRoute != AppRoutes.chat) {
      Get.toNamed(AppRoutes.chat, arguments: arguments);
      return;
    }
    final openClientUid = switch (Get.arguments) {
      {'clientUid': String uid} => uid,
      _ => null,
    };
    if (openClientUid != clientUid) {
      Get.offNamed(AppRoutes.chat, arguments: arguments, preventDuplicates: false);
    }
  }

  void _goHome() {
    if (Get.currentRoute != AppRoutes.home) Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    super.onClose();
  }
}
