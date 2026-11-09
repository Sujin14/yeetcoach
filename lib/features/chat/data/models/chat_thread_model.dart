import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_thread.dart';

/// Firestore mapping for chats/{chatId}. Chats started from YeetFit carry
/// lastMessageTime but no updatedAt, so the later of the two is used.
class ChatThreadModel extends ChatThread {
  const ChatThreadModel({
    required super.id,
    required super.clientUid,
    required super.lastMessage,
    super.lastActivityAt,
    super.lastMessageTime,
    super.clearedAt,
  });

  factory ChatThreadModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String coachUid,
  }) {
    final data = doc.data() ?? const <String, dynamic>{};
    final participants = (data['participants'] as List?)?.whereType<String>() ?? const <String>[];
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
    final lastMessageTime = (data['lastMessageTime'] as Timestamp?)?.toDate();
    final clearedAtRaw = data['clearedAt'];
    DateTime? clearedAt;
    if (clearedAtRaw is Map) {
      clearedAt = (clearedAtRaw[coachUid] as Timestamp?)?.toDate();
    }
    return ChatThreadModel(
      id: doc.id,
      clientUid: participants.firstWhere((uid) => uid != coachUid, orElse: () => ''),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastActivityAt: _later(updatedAt, lastMessageTime),
      lastMessageTime: lastMessageTime,
      clearedAt: clearedAt,
    );
  }

  static Map<String, dynamic> toCreateMap({
    required String coachUid,
    required String clientUid,
    required String clientName,
  }) {
    return {
      'participants': [coachUid, clientUid],
      'participantName': clientName,
      'lastMessage': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// YeetFit's chat list reads lastMessage / lastMessageTime; the spec's updatedAt is kept too.
  static Map<String, dynamic> toNewMessageMap(String text) {
    return {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

DateTime? _later(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isAfter(b) ? a : b;
}
