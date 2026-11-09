import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_participant.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../datasources/firestore_chat_service.dart';

class ChatRepository implements IChatRepository {
  final FirestoreChatService _service;

  ChatRepository({FirestoreChatService? service}) : _service = service ?? FirestoreChatService();

  @override
  Stream<List<ChatThread>> watchCoachChats(String coachUid) => _service.watchCoachChats(coachUid);

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId, String uid, {DateTime? clearedAt}) =>
      _service.watchMessages(chatId, uid, clearedAt: clearedAt);

  @override
  Stream<DateTime?> watchClearedAt(String chatId, String uid) =>
      _service.watchClearedAt(chatId, uid);

  @override
  Stream<int> watchUnreadCount(String chatId, String senderUid, String viewerUid) =>
      _service.watchUnreadCount(chatId, senderUid, viewerUid);

  @override
  Future<ChatParticipant?> getParticipant(String uid) => _service.getParticipant(uid);

  @override
  Future<void> sendMessage({
    required String coachUid,
    required ChatParticipant client,
    required String text,
  }) =>
      _service.sendMessage(coachUid: coachUid, client: client, text: text);

  @override
  Future<void> markAsRead(String chatId, String senderUid) =>
      _service.markAsRead(chatId, senderUid);

  @override
  Future<void> deleteMessagesForMe(String chatId, List<String> messageIds, String uid) =>
      _service.deleteMessagesForMe(chatId, messageIds, uid);

  @override
  Future<void> clearChatForMe(String chatId, String uid) =>
      _service.clearChatForMe(chatId, uid);
}
