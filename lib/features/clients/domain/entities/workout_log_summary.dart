import 'package:flutter/foundation.dart';

/// The workout a client logged for a day in YeetFit.
@immutable
class WorkoutLogSummary {
  final String type;
  final int durationMinutes;
  final String intensity;
  final bool fromPlan;

  const WorkoutLogSummary({
    required this.type,
    required this.durationMinutes,
    this.intensity = '',
    this.fromPlan = false,
  });

  WorkoutLogSummary copyWith({
    String? type,
    int? durationMinutes,
    String? intensity,
    bool? fromPlan,
  }) {
    return WorkoutLogSummary(
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      fromPlan: fromPlan ?? this.fromPlan,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogSummary &&
          other.type == type &&
          other.durationMinutes == durationMinutes &&
          other.intensity == intensity &&
          other.fromPlan == fromPlan;

  @override
  int get hashCode => Object.hash(type, durationMinutes, intensity, fromPlan);
}
