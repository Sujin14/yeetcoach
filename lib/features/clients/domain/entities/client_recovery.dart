import 'package:flutter/foundation.dart';
import 'package:yeetcoach/features/home/domain/entities/recovery_level.dart';

/// The recovery score YeetFit mirrors onto clients/{uid}.
@immutable
class ClientRecovery {
  /// 0–100, or null when the client has never calculated one.
  final int? score;
  final RecoveryLevel? level;
  final DateTime? updatedAt;

  const ClientRecovery({this.score, this.level, this.updatedAt});

  static const empty = ClientRecovery();

  bool get hasScore => score != null;

  ClientRecovery copyWith({int? score, RecoveryLevel? level, DateTime? updatedAt}) {
    return ClientRecovery(
      score: score ?? this.score,
      level: level ?? this.level,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientRecovery &&
          other.score == score &&
          other.level == level &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(score, level, updatedAt);
}
