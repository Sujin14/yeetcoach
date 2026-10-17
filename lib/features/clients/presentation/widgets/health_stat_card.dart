import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/widgets/count_up_text.dart';
import '../../domain/entities/daily_goal_metric.dart';

class HealthStatCard extends StatelessWidget {
  final String emoji;

  /// Static text, used when there is no number to count up (e.g. "Not logged").
  final String value;

  /// When set, the value counts up from 0 to [target] on first appearance instead of showing [value].
  final ({double target, String Function(double current) format})? countUp;
  final String label;
  final GoalProgress progress;

  const HealthStatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.progress,
    this.countUp,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final countUp = this.countUp;
    final valueColor = switch (progress) {
      GoalProgress.met => AppColors.primary,
      GoalProgress.partial => AppColors.statusFair,
      GoalProgress.missing => AppColors.statusNone,
    };
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: const Color(0x0D000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: AppSpacing.sm),
            if (countUp == null)
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(color: valueColor),
              )
            else
              CountUpText(
                value: countUp.target,
                format: countUp.format,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(color: valueColor),
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: AppColors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}
