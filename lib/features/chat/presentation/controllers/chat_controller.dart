import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_party.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_type.dart';
import 'package:yeetcoach/features/calls/domain/repositories/i_call_repository.dart';
import 'package:yeetcoach/features/coach/domain/repositories/i_coach_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_participant.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/repositories/i_chat_repository.dart';

/// One coach↔client conversation. Arguments: {clientUid: String, name?: String, photoUrl?: String}.
class ChatController extends GetxController {
  final IChatRepository _repository;
  final ICallRepository _callRepo;
  final ICoachRepository _coachRepo;
  final FirebaseAuth _auth;
  final Map<dynamic, dynamic> _arguments;

  ChatController(
    this._repository,
    this._callRepo,
    this._coachRepo, {
    required Map<dynamic, dynamic> arguments,
    FirebaseAuth? auth,
  })  : _arguments = arguments,
        _auth = auth ?? FirebaseAuth.instance;

  final Rx<ChatParticipant?> client = Rx<ChatParticipant?>(null);

  /// Newest first, for a reversed list.
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxBool canSend = false.obs;
  final RxBool isStartingCall = false.obs;
  final RxBool isDeleting = false.obs;

  final RxBool selectionMode = false.obs;
  final RxSet<String> selectedIds = <String>{}.obs;

  final TextEditingController textController = TextEditingController();

  String coachUid = '';
  String clientUid = '';
  String _chatId = '';
  DateTime? _clearedAt;

  StreamSubscription<List<ChatMessage>>? _messagesSub;
  StreamSubscription<DateTime?>? _clearedAtSub;
  bool _isMarkingRead = false;
  bool _markReadAgain = false;

  @override
  void onInit() {
    super.onInit();
    coachUid = _auth.currentUser?.uid ?? '';
    clientUid = switch (_arguments) {
      {'clientUid': String uid} => uid,
      _ => '',
    };
    if (coachUid.isEmpty || clientUid.isEmpty) {
      logDebug('ChatController: missing coach or client uid');
      isLoading.value = false;
      return;
    }
    _chatId = ChatThread.idFor(coachUid, clientUid);

    final name = switch (_arguments) {
      {'name': String name} when name.isNotEmpty => name,
      _ => null,
    };
    if (name == null) {
      _loadClient();
    } else {
      final photoUrl = switch (_arguments) {
        {'photoUrl': String url} => url,
        _ => '',
      };
      client.value = ChatParticipant(uid: clientUid, name: name, photoUrl: photoUrl);
    }

    textController.addListener(_updateCanSend);
    _clearedAtSub = _repository.watchClearedAt(_chatId, coachUid).listen(
      _onClearedAt,
      onError: (Object e) {
        logDebug('ChatController: watchClearedAt error: $e');
        // Still try to load messages without a clear cutoff.
        _subscribeMessages(null);
      },
    );
    _markAsRead();
  }

  void _onClearedAt(DateTime? clearedAt) {
    if (_messagesSub != null && clearedAt == _clearedAt) return;
    _clearedAt = clearedAt;
    _subscribeMessages(clearedAt);
  }

  void _subscribeMessages(DateTime? clearedAt) {
    _messagesSub?.cancel();
    _messagesSub = _repository.watchMessages(_chatId, coachUid, clearedAt: clearedAt).listen(
      _onMessages,
      onError: (Object e) {
        // Expected before the first message if the chat document doesn't exist yet.
        logDebug('ChatController: watchMessages error: $e');
        isLoading.value = false;
      },
    );
  }

  void _updateCanSend() => canSend.value = textController.text.trim().isNotEmpty;

  Future<void> _loadClient() async {
    try {
      client.value = await _repository.getParticipant(clientUid);
    } catch (e) {
      logDebug('ChatController: loading client failed: $e');
    }
    client.value ??= ChatParticipant(uid: clientUid, name: 'Client');
  }

  void _onMessages(List<ChatMessage> latest) {
    messages.assignAll(latest);
    isLoading.value = false;
    // Drop selection of messages that disappeared (soft-deleted / cleared).
    final liveIds = latest.map((m) => m.id).toSet();
    selectedIds.removeWhere((id) => !liveIds.contains(id));
    if (selectedIds.isEmpty) selectionMode.value = false;
    // Messages that arrive while the chat is open are read immediately.
    if (latest.any((message) => message.senderId == clientUid && message.status.isUnread)) {
      _markAsRead();
    }
  }

  Future<void> _markAsRead() async {
    if (_isMarkingRead) {
      _markReadAgain = true;
      return;
    }
    _isMarkingRead = true;
    try {
      do {
        _markReadAgain = false;
        await _repository.markAsRead(_chatId, clientUid);
      } while (_markReadAgain);
    } catch (e) {
      logDebug('ChatController: markAsRead failed: $e');
    } finally {
      _isMarkingRead = false;
    }
  }

  void enterSelection(String id) {
    final message = messages.firstWhereOrNull((m) => m.id == id);
    if (message == null || message.isPending) return;
    selectionMode.value = true;
    selectedIds
      ..clear()
      ..add(id);
    HapticFeedback.lightImpact();
  }

  void toggleSelection(String id) {
    final message = messages.firstWhereOrNull((m) => m.id == id);
    if (message == null || message.isPending) return;
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    if (selectedIds.isEmpty) selectionMode.value = false;
  }

  void clearSelection() {
    selectedIds.clear();
    selectionMode.value = false;
  }

  Future<void> copySelectedMessage() async {
    if (selectedIds.length != 1) return;
    final id = selectedIds.first;
    final message = messages.firstWhereOrNull((m) => m.id == id);
    if (message == null) return;
    await Clipboard.setData(ClipboardData(text: message.text));
    clearSelection();
    showSuccessSnackbar('Copied');
  }

  Future<bool> deleteSelectedMessages() async {
    if (selectedIds.isEmpty || isDeleting.value || _chatId.isEmpty) return false;
    isDeleting.value = true;
    final ids = selectedIds.toList();
    try {
      await _repository.deleteMessagesForMe(_chatId, ids, coachUid);
      clearSelection();
      showSuccessSnackbar('Deleted for you');
      return true;
    } catch (e) {
      logDebug('ChatController: deleteMessagesForMe failed: $e');
      showErrorSnackbar('Could not delete messages. Please try again.');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  /// Creates the ringing call document and opens the call screen.
  Future<void> startCall(CallType type) async {
    final participant = client.value;
    final coachId = _auth.currentUser?.uid;
    if (participant == null || coachId == null || isStartingCall.value) return;
    isStartingCall.value = true;
    try {
      final receiver = CallParty(
        uid: participant.uid,
        name: participant.name,
        photoUrl: participant.photoUrl,
      );
      final callId = await _callRepo.startCall(
        caller: await _callerParty(coachId),
        receiver: receiver,
        type: type,
      );
      logDebug('ChatController: started ${type.name} call $callId');
      Get.toNamed(AppRoutes.call, arguments: {'callId': callId, 'type': type, 'party': receiver});
    } catch (e) {
      logDebug('ChatController: starting call failed: $e');
      showErrorSnackbar('Could not start call');
    } finally {
      isStartingCall.value = false;
    }
  }

  /// The coach profile is preferred; the auth account is the fallback if it can't be read.
  Future<CallParty> _callerParty(String coachId) async {
    try {
      final coach = await _coachRepo.getCoach(coachId);
      if (coach != null) {
        return CallParty(uid: coachId, name: coach.name, photoUrl: coach.profileImageUrl ?? '');
      }
    } catch (e) {
      logDebug('ChatController: coach profile unavailable for call: $e');
    }
    final user = _auth.currentUser;
    return CallParty(
      uid: coachId,
      name: user?.displayName ?? 'Your coach',
      photoUrl: user?.photoURL ?? '',
    );
  }

  /// Soft-clears this conversation for the coach. Returns whether the write succeeded.
  Future<bool> clearChatForMe() async {
    if (_chatId.isEmpty || isDeleting.value) return false;
    isDeleting.value = true;
    try {
      await _repository.clearChatForMe(_chatId, coachUid);
      return true;
    } catch (e) {
      logDebug('ChatController: clearChatForMe failed: $e');
      showErrorSnackbar('Could not delete the chat. Please try again.');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> send() async {
    final text = textController.text.trim();
    if (text.isEmpty || isSending.value || _chatId.isEmpty) return;
    isSending.value = true;
    textController.clear();
    try {
      await _repository.sendMessage(
        coachUid: coachUid,
        client: client.value ?? ChatParticipant(uid: clientUid, name: 'Client'),
        text: text,
      );
    } catch (e) {
      logDebug('ChatController: sendMessage failed: $e');
      // Restored so the coach doesn't have to retype it, unless they've started a new one.
      if (textController.text.isEmpty) textController.text = text;
      showErrorSnackbar('Message not sent. Please try again.');
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    _messagesSub?.cancel();
    _clearedAtSub?.cancel();
    textController.dispose();
    super.onClose();
  }
}
