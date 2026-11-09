import 'package:flutter/foundation.dart';
import 'package:yeetcoach/features/home/domain/entities/recovery_level.dart';

/// One day of the recovery chart; [score] is null when there's no data for [date].
@immutable
class RecoveryDay {
  final DateTime date;
  final int? score;
  final RecoveryLevel? level;

  const RecoveryDay({required this.date, this.score, this.level});

  RecoveryDay copyWith({DateTime? date, int? score, RecoveryLevel? level}) {
    return RecoveryDay(
      date: date ?? this.date,
      score: score ?? this.score,
      level: level ?? this.level,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryDay &&
          other.date == date &&
          other.score == score &&
          other.level == level;

  @override
  int get hashCode => Object.hash(date, score, level);
}
