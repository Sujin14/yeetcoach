import 'package:flutter/foundation.dart';

/// One bar of the weekly recovery chart; [score] is null when there's no data for [date].
@immutable
class RecoveryDay {
  final DateTime date;
  final int? score;

  const RecoveryDay({required this.date, this.score});

  RecoveryDay copyWith({DateTime? date, int? score}) {
    return RecoveryDay(date: date ?? this.date, score: score ?? this.score);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryDay && other.date == date && other.score == score;

  @override
  int get hashCode => Object.hash(date, score);
}
