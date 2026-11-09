import 'package:flutter/foundation.dart';
import 'message_status.dart';

@immutable
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final MessageStatus status;

  /// Uids that soft-deleted this message for themselves. Not written on send.
  final List<String> deletedFor;

  /// True until the server has accepted the write.
  final bool isPending;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.status,
    this.deletedFor = const [],
    this.isPending = false,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? sentAt,
    MessageStatus? status,
    List<String>? deletedFor,
    bool? isPending,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      deletedFor: deletedFor ?? this.deletedFor,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          other.id == id &&
          other.senderId == senderId &&
          other.text == text &&
          other.sentAt == sentAt &&
          other.status == status &&
          listEquals(other.deletedFor, deletedFor) &&
          other.isPending == isPending;

  @override
  int get hashCode =>
      Object.hash(id, senderId, text, sentAt, status, Object.hashAll(deletedFor), isPending);
}
