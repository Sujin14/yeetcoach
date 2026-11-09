import '../entities/chat_message.dart';
import '../entities/chat_participant.dart';
import '../entities/chat_thread.dart';

abstract class IChatRepository {
  /// Chats the coach takes part in, most recently active first.
  Stream<List<ChatThread>> watchCoachChats(String coachUid);

  /// Newest messages of a chat (newest first), excluding [uid]'s soft-deletes
  /// and anything at or before [clearedAt].
  Stream<List<ChatMessage>> watchMessages(String chatId, String uid, {DateTime? clearedAt});

  /// Live clearedAt for [uid] on the chat document.
  Stream<DateTime?> watchClearedAt(String chatId, String uid);

  /// Unread from [senderUid], excluding soft-deleted / cleared rows for [viewerUid].
  Stream<int> watchUnreadCount(String chatId, String senderUid, String viewerUid);

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

  /// Soft-deletes [messageIds] for [uid] only.
  Future<void> deleteMessagesForMe(String chatId, List<String> messageIds, String uid);

  /// Clears the chat for [uid] only (sets clearedAt; does not delete docs).
  Future<void> clearChatForMe(String chatId, String uid);
}
