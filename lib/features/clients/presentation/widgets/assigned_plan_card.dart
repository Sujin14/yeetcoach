import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/assigned_workout_plan.dart';
import '../controllers/client_detail_controller.dart';
import 'client_detail_section_shimmers.dart';
import 'client_section.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// The latest workout plan; there's no plan detail screen, so "View full plan" expands in place.
class AssignedPlanCard extends GetView<ClientDetailController> {
  static const _previewCount = 3;

  const AssignedPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSectionLoading(ClientDetailSection.plan)) {
        return const AssignedPlanShimmer();
      }
      final plan = controller.latestPlan.value;
      if (plan == null) {
        return ClientCard(
          child: Row(
            children: [
              const Icon(Icons.fitness_center_outlined, color: AppColors.statusNone, size: 22),
              const SizedBox(width: AppSpacing.smd),
              Text(
                'No workout plan assigned yet',
                style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
              ),
            ],
          ),
        );
      }

      final expanded = controller.isPlanExpanded.value;
      final exercises = plan.exercises.where((exercise) => exercise.name.isNotEmpty).toList();
      final visible = expanded ? exercises : exercises.take(_previewCount).toList();
      final createdAt = plan.createdAt;

      return ClientCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.title.isEmpty ? 'Workout plan' : plan.title,
              style: _textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            if (createdAt != null)
              Text(
                'Created ${DateFormat.yMMMd().format(createdAt)}',
                style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
              ),
            const SizedBox(height: AppSpacing.smd),
            if (exercises.isEmpty)
              Text(
                'No exercises in this plan',
                style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
              ),
            for (final exercise in visible) _ExerciseRow(exercise: exercise, showDetails: expanded),
            if (exercises.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: controller.togglePlanExpanded,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(
                  expanded ? 'Show less' : 'View full plan',
                  style: _textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _ExerciseRow extends StatelessWidget {
  final AssignedExercise exercise;
  final bool showDetails;

  const _ExerciseRow({required this.exercise, required this.showDetails});

  String get _details {
    final sets = exercise.sets;
    final reps = exercise.reps;
    final volume = switch ((sets, reps)) {
      (final int s, final int r) => '$s × $r${exercise.repsType == 'min' ? ' min' : ''}',
      (final int s, null) => '$s sets',
      (null, final int r) => '$r${exercise.repsType == 'min' ? ' min' : ' reps'}',
      _ => '',
    };
    return [exercise.day, volume].where((part) => part.isNotEmpty).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final details = showDetails ? _details : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.onSurface),
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
