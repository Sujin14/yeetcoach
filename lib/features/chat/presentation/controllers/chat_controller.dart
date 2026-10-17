import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController textController = TextEditingController();

  String coachUid = '';
  String clientUid = '';
  String _chatId = '';

  StreamSubscription<List<ChatMessage>>? _messagesSub;
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
    _messagesSub = _repository.watchMessages(_chatId).listen(
      _onMessages,
      onError: (Object e) {
        // Expected before the first message if the chat document doesn't exist yet.
        logDebug('ChatController: watchMessages error: $e');
        isLoading.value = false;
      },
    );
    _markAsRead();
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

  /// Deletes this conversation. Returns whether the chat document was removed.
  Future<bool> deleteChat() async {
    if (_chatId.isEmpty || isDeleting.value) return false;
    isDeleting.value = true;
    try {
      await _repository.deleteChat(_chatId);
      return true;
    } catch (e) {
      logDebug('ChatController: deleteChat failed: $e');
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
    textController.dispose();
    super.onClose();
  }
}
