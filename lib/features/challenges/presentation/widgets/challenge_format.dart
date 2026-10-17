import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_type.dart';

IconData challengeTypeIcon(ChallengeType type) => switch (type) {
      ChallengeType.steps => Icons.directions_walk_rounded,
      ChallengeType.water => Icons.water_drop_outlined,
      ChallengeType.sleep => Icons.bedtime_outlined,
      ChallengeType.workout => Icons.fitness_center_rounded,
      ChallengeType.calories => Icons.local_fire_department_outlined,
    };

/// "10,000 steps/day", "7 hours/night", "5 workouts total".
String formatChallengeTarget(ChallengeType type, int value) =>
    '${NumberFormat.decimalPattern().format(value)} ${type.unit}${type.period}';

String formatChallengeDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

/// The timing line under a challenge's progress bar.
({String text, bool urgent}) challengeTimingLabel(Challenge challenge, DateTime now) {
  if (challenge.isEndedAt(now)) {
    return (text: 'Ended ${DateFormat('d MMM').format(challenge.endDate)}', urgent: false);
  }
  if (!challenge.hasStartedAt(now)) {
    final days = challenge.daysUntilStartAt(now);
    return (text: days <= 1 ? 'Starts tomorrow' : 'Starts in $days days', urgent: false);
  }
  final days = challenge.daysLeftAt(now);
  return (text: days == 1 ? '1 day left' : '$days days left', urgent: days <= 2);
}
