import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/message_status.dart';

/// Firestore mapping for chats/{chatId}/messages/{messageId}, shared with YeetFit's MessageModel.
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.text,
    required super.sentAt,
    required super.status,
    super.deletedFor,
    super.isPending,
  });

  factory ChatMessageModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final deletedFor = (data['deletedFor'] as List?)?.whereType<String>().toList() ?? const <String>[];
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      // YeetFit writes the body to `content` only.
      text: data['text'] as String? ?? data['content'] as String? ?? '',
      // A serverTimestamp() reads as null until the server confirms the write.
      sentAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: MessageStatus.values.asNameMap()[data['status']] ?? MessageStatus.sent,
      deletedFor: List.unmodifiable(deletedFor),
      isPending: doc.metadata.hasPendingWrites,
    );
  }

  /// YeetFit renders `content` and only loads messages whose `participants`
  /// contain the reader's uid, so both are written alongside `text`.
  /// [deletedFor] is omitted — soft-delete is applied later via arrayUnion.
  static Map<String, dynamic> toCreateMap({
    required String senderId,
    required List<String> participants,
    required String participantName,
    required String text,
  }) {
    return {
      'senderId': senderId,
      'text': text,
      'content': text,
      'participants': participants,
      'participantName': participantName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': MessageStatus.sent.name,
    };
  }
}
