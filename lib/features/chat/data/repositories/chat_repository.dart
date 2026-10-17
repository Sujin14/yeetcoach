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
  Stream<List<ChatMessage>> watchMessages(String chatId) => _service.watchMessages(chatId);

  @override
  Stream<int> watchUnreadCount(String chatId, String senderUid) =>
      _service.watchUnreadCount(chatId, senderUid);

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
  Future<void> deleteChat(String chatId) => _service.deleteChat(chatId);
}
