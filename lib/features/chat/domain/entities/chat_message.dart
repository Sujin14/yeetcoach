import 'package:flutter/foundation.dart';
import 'message_status.dart';

@immutable
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final MessageStatus status;

  /// True until the server has accepted the write.
  final bool isPending;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.status,
    this.isPending = false,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? sentAt,
    MessageStatus? status,
    bool? isPending,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
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
          other.isPending == isPending;

  @override
  int get hashCode => Object.hash(id, senderId, text, sentAt, status, isPending);
}
