import 'package:flutter/foundation.dart';

/// One chats/{chatId} document as seen by the signed-in coach.
@immutable
class ChatThread {
  final String id;
  final String clientUid;
  final String lastMessage;

  /// Null only for a chat that has never had a message.
  final DateTime? lastActivityAt;

  const ChatThread({
    required this.id,
    required this.clientUid,
    required this.lastMessage,
    this.lastActivityAt,
  });

  /// Shared with YeetFit: both uids sorted and joined with '_'.
  static String idFor(String coachUid, String clientUid) =>
      ([coachUid, clientUid]..sort()).join('_');

  ChatThread copyWith({
    String? id,
    String? clientUid,
    String? lastMessage,
    DateTime? lastActivityAt,
  }) {
    return ChatThread(
      id: id ?? this.id,
      clientUid: clientUid ?? this.clientUid,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatThread &&
          other.id == id &&
          other.clientUid == clientUid &&
          other.lastMessage == lastMessage &&
          other.lastActivityAt == lastActivityAt;

  @override
  int get hashCode => Object.hash(id, clientUid, lastMessage, lastActivityAt);
}
