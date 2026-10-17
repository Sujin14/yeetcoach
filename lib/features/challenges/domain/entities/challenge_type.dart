/// Stored as [name] in both `type` and YeetFit's `metric` field.
/// YeetFit updates participant progress for steps, water, sleep and calories only.
enum ChallengeType {
  steps(label: 'Steps', unit: 'steps', period: '/day', defaultTarget: 10000, maxTarget: 100000),
  water(label: 'Water', unit: 'glasses', period: '/day', defaultTarget: 8, maxTarget: 30),
  sleep(label: 'Sleep', unit: 'hours', period: '/night', defaultTarget: 7, maxTarget: 16),
  workout(label: 'Workout', unit: 'workouts', period: ' total', defaultTarget: 5, maxTarget: 100),
  calories(label: 'Calories', unit: 'kcal', period: '/day', defaultTarget: 2000, maxTarget: 10000);

  final String label;
  final String unit;

  /// Appended after the unit, e.g. "10,000 steps/day".
  final String period;
  final int defaultTarget;
  final int maxTarget;

  const ChallengeType({
    required this.label,
    required this.unit,
    required this.period,
    required this.defaultTarget,
    required this.maxTarget,
  });

  /// False until YeetFit tracks progress for this type; such challenges can't be created.
  bool get isAvailable => this != ChallengeType.workout;

  static ChallengeType get firstAvailable => values.firstWhere((type) => type.isAvailable);

  static ChallengeType? tryParse(Object? value) {
    if (value is! String) return null;
    return ChallengeType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ChallengeType.steps,
    );
  }
}

enum ChallengeStatus {
  active,
  ended;

  static ChallengeStatus parse(Object? value) => ChallengeStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => ChallengeStatus.active,
      );
}

const List<int> challengeDurations = [7, 14, 30];
