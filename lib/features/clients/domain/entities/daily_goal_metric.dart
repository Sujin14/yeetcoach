import 'package:flutter/foundation.dart';

enum GoalProgress { met, partial, missing }

/// One day's logged value for a goal-based metric (sleep hours, water glasses, steps).
@immutable
class DailyGoalMetric {
  final double value;
  final double goal;

  const DailyGoalMetric({required this.value, required this.goal});

  GoalProgress get progress {
    if (value <= 0) return GoalProgress.missing;
    return goal > 0 && value >= goal ? GoalProgress.met : GoalProgress.partial;
  }

  DailyGoalMetric copyWith({double? value, double? goal}) {
    return DailyGoalMetric(value: value ?? this.value, goal: goal ?? this.goal);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyGoalMetric && other.value == value && other.goal == goal;

  @override
  int get hashCode => Object.hash(value, goal);
}
