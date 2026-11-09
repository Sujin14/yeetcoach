import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import '../../domain/entities/chat_participant.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/repositories/i_chat_repository.dart';

class ChatInboxController extends GetxController {
  final IChatRepository _repository;
  final FirebaseAuth _auth;

  ChatInboxController(this._repository, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final RxList<ChatThread> threads = <ChatThread>[].obs;

  /// Keyed by client uid; filled in as each profile loads.
  final RxMap<String, ChatParticipant> participants = <String, ChatParticipant>{}.obs;

  /// Keyed by chat id.
  final RxMap<String, int> unreadCounts = <String, int>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  StreamSubscription<List<ChatThread>>? _threadsSub;
  final Map<String, StreamSubscription<int>> _unreadSubs = {};
  final Set<String> _requestedProfiles = {};

  @override
  void onInit() {
    super.onInit();
    final coachUid = _auth.currentUser?.uid;
    if (coachUid == null) {
      isLoading.value = false;
      return;
    }
    _threadsSub = _repository.watchCoachChats(coachUid).listen(
      _onThreads,
      onError: (Object e) {
        logDebug('ChatInboxController: watchCoachChats error: $e');
        hasError.value = true;
        isLoading.value = false;
      },
    );
  }

  void _onThreads(List<ChatThread> latest) {
    threads.assignAll(latest);
    hasError.value = false;
    isLoading.value = false;

    final liveIds = latest.map((thread) => thread.id).toSet();
    final staleIds = _unreadSubs.keys.where((id) => !liveIds.contains(id)).toList();
    for (final id in staleIds) {
      _unreadSubs.remove(id)?.cancel();
      unreadCounts.remove(id);
    }

    final coachUid = _auth.currentUser?.uid;
    for (final thread in latest) {
      _unreadSubs.putIfAbsent(
        thread.id,
        () => _repository
            .watchUnreadCount(thread.id, thread.clientUid, coachUid ?? '')
            .listen(
              (count) => unreadCounts[thread.id] = count,
              onError: (Object e) => logDebug('ChatInboxController: unread count error: $e'),
            ),
      );
      if (_requestedProfiles.add(thread.clientUid)) _loadParticipant(thread.clientUid);
    }
  }

  Future<void> _loadParticipant(String uid) async {
    try {
      participants[uid] =
          await _repository.getParticipant(uid) ?? ChatParticipant(uid: uid, name: 'Client');
    } catch (e) {
      logDebug('ChatInboxController: loading participant $uid failed: $e');
      // Retried on the next inbox update.
      _requestedProfiles.remove(uid);
    }
  }

  void openChat(ChatThread thread) {
    final participant = participants[thread.clientUid];
    Get.toNamed(AppRoutes.chat, arguments: {
      'clientUid': thread.clientUid,
      'name': ?participant?.name,
      'photoUrl': ?participant?.photoUrl,
    });
  }

  @override
  void onClose() {
    _threadsSub?.cancel();
    for (final sub in _unreadSubs.values) {
      sub.cancel();
    }
    super.onClose();
  }
}
