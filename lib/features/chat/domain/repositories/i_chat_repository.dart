import '../entities/chat_message.dart';
import '../entities/chat_participant.dart';
import '../entities/chat_thread.dart';

abstract class IChatRepository {
  /// Chats the coach takes part in, most recently active first.
  Stream<List<ChatThread>> watchCoachChats(String coachUid);

  /// The newest messages of a chat, newest first.
  Stream<List<ChatMessage>> watchMessages(String chatId);

  /// Number of messages from [senderUid] in the chat that are not yet read.
  Stream<int> watchUnreadCount(String chatId, String senderUid);

  /// Name and photo of [uid] from users/{uid}.
  Future<ChatParticipant?> getParticipant(String uid);

  /// Sends [text] as the coach, creating the chat document on the first message.
  Future<void> sendMessage({
    required String coachUid,
    required ChatParticipant client,
    required String text,
  });

  /// Marks every unread message from [senderUid] in the chat as read.
  Future<void> markAsRead(String chatId, String senderUid);

  /// Deletes the chat document and every message in it.
  Future<void> deleteChat(String chatId);
}
