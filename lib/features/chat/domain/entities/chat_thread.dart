import 'package:flutter/foundation.dart';

/// One chats/{chatId} document as seen by the signed-in coach.
@immutable
class ChatThread {
  final String id;
  final String clientUid;
  final String lastMessage;

  /// Null only for a chat that has never had a message.
  final DateTime? lastActivityAt;

  /// The chat's lastMessageTime field (used for clear-for-me inbox filtering).
  final DateTime? lastMessageTime;

  /// When the coach cleared this chat for themselves, if ever.
  final DateTime? clearedAt;

  const ChatThread({
    required this.id,
    required this.clientUid,
    required this.lastMessage,
    this.lastActivityAt,
    this.lastMessageTime,
    this.clearedAt,
  });

  /// Shared with YeetFit: both uids sorted and joined with '_'.
  static String idFor(String coachUid, String clientUid) =>
      ([coachUid, clientUid]..sort()).join('_');

  /// Hidden from the inbox until a newer message arrives.
  bool get isClearedForViewer {
    final cleared = clearedAt;
    if (cleared == null) return false;
    final last = lastMessageTime;
    return last == null || !last.isAfter(cleared);
  }

  ChatThread copyWith({
    String? id,
    String? clientUid,
    String? lastMessage,
    DateTime? lastActivityAt,
    DateTime? lastMessageTime,
    DateTime? clearedAt,
  }) {
    return ChatThread(
      id: id ?? this.id,
      clientUid: clientUid ?? this.clientUid,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      clearedAt: clearedAt ?? this.clearedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatThread &&
          other.id == id &&
          other.clientUid == clientUid &&
          other.lastMessage == lastMessage &&
          other.lastActivityAt == lastActivityAt &&
          other.lastMessageTime == lastMessageTime &&
          other.clearedAt == clearedAt;

  @override
  int get hashCode =>
      Object.hash(id, clientUid, lastMessage, lastActivityAt, lastMessageTime, clearedAt);
}
