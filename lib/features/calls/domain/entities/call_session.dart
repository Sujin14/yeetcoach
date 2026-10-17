import 'package:flutter/foundation.dart';
import 'call_status.dart';
import 'call_type.dart';

/// A 1-to-1 call (calls/{callId}) between a coach and a client; either side may call.
@immutable
class CallSession {
  final String id;
  final String callerId;
  final String receiverId;

  /// Metered room both parties join.
  final String channelId;
  final CallType type;
  final CallStatus status;

  /// Set by the receiver when they answer.
  final DateTime? startedAt;
  final DateTime? endedAt;

  const CallSession({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.channelId,
    required this.type,
    required this.status,
    this.startedAt,
    this.endedAt,
  });

  CallSession copyWith({
    String? id,
    String? callerId,
    String? receiverId,
    String? channelId,
    CallType? type,
    CallStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return CallSession(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      channelId: channelId ?? this.channelId,
      type: type ?? this.type,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallSession &&
          other.id == id &&
          other.callerId == callerId &&
          other.receiverId == receiverId &&
          other.channelId == channelId &&
          other.type == type &&
          other.status == status &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt;

  @override
  int get hashCode =>
      Object.hash(id, callerId, receiverId, channelId, type, status, startedAt, endedAt);
}
