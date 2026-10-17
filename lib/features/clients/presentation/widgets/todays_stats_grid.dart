import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/daily_goal_metric.dart';
import '../controllers/client_detail_controller.dart';
import 'client_detail_section_shimmers.dart';
import 'health_stat_card.dart';

/// 6.0 → "6", 6.5 → "6.5".
String _trim(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);

/// Formats a counting value with the same precision as its final [target].
String _trimTowards(double current, double target) =>
    target == target.roundToDouble() ? current.round().toString() : current.toStringAsFixed(1);

String _capitalise(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1).replaceAll('_', ' ');

/// Sleep, water, steps and workout for today in a 2×2 grid.
class TodaysStatsGrid extends GetView<ClientDetailController> {
  const TodaysStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _cell(ClientDetailSection.sleep, _sleepCard)),
            const SizedBox(width: AppSpacing.smd),
            Expanded(child: _cell(ClientDetailSection.water, _waterCard)),
          ],
        ),
        const SizedBox(height: AppSpacing.smd),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _cell(ClientDetailSection.steps, _stepsCard)),
            const SizedBox(width: AppSpacing.smd),
            Expanded(child: _cell(ClientDetailSection.workout, _workoutCard)),
          ],
        ),
      ],
    );
  }

  Widget _cell(ClientDetailSection section, Widget Function() buildCard) {
    return Obx(() => controller.isSectionLoading(section)
        ? const HealthStatCardShimmer()
        : buildCard());
  }

  Widget _sleepCard() {
    final sleep = controller.sleep.value;
    return HealthStatCard(
      emoji: '💤',
      label: 'Sleep',
      value: sleep == null ? 'Not logged' : '${_trim(sleep.value)} / ${_trim(sleep.goal)} hrs',
      countUp: sleep == null
          ? null
          : (
              target: sleep.value,
              format: (current) =>
                  '${_trimTowards(current, sleep.value)} / ${_trim(sleep.goal)} hrs',
            ),
      progress: sleep?.progress ?? GoalProgress.missing,
    );
  }

  Widget _waterCard() {
    final water = controller.water.value;
    return HealthStatCard(
      emoji: '💧',
      label: 'Water',
      value: water == null
          ? 'Not logged'
          : '${_trim(water.value)} / ${_trim(water.goal)} glasses',
      countUp: water == null
          ? null
          : (
              target: water.value,
              format: (current) =>
                  '${_trimTowards(current, water.value)} / ${_trim(water.goal)} glasses',
            ),
      progress: water?.progress ?? GoalProgress.missing,
    );
  }

  Widget _stepsCard() {
    final steps = controller.steps.value;
    final numbers = NumberFormat.decimalPattern();
    return HealthStatCard(
      emoji: '👟',
      label: 'Steps',
      value: steps == null ? '—' : '${numbers.format(steps.value.round())} steps',
      countUp: steps == null
          ? null
          : (
              target: steps.value,
              format: (current) => '${numbers.format(current.round())} steps',
            ),
      progress: steps?.progress ?? GoalProgress.missing,
    );
  }

  Widget _workoutCard() {
    final workout = controller.workout.value;
    final String value;
    if (controller.isWorkoutRestricted.value) {
      value = 'Not shared';
    } else if (workout == null) {
      value = 'Not logged';
    } else {
      value = '${_capitalise(workout.type)} ${workout.durationMinutes}m'.trim();
    }
    return HealthStatCard(
      emoji: '🏋️',
      label: 'Workout',
      value: value,
      progress: workout == null ? GoalProgress.missing : GoalProgress.met,
    );
  }
}
