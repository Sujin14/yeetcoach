import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/workout_plan.dart';
import '../screens/youtube_preview_screen.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

String _exerciseSummary(ExerciseEntry ex) {
  final volume = ex.reps != null ? '${ex.reps} reps' : '${ex.durationMinutes ?? 0}min';
  return '${ex.sets} sets × $volume · ${ex.restSeconds}s rest';
}

class ExerciseCard extends StatelessWidget {
  final ExerciseEntry exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExerciseCard({super.key, required this.exercise, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.smd),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    overflow: TextOverflow.ellipsis,
                    style: _textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _exerciseSummary(exercise),
                    style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (exercise.youtubeUrl.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline,
                        size: 18, color: AppColors.primary),
                    tooltip: 'Preview video',
                    onPressed: () =>
                        Get.to(() => YoutubePreviewScreen(url: exercise.youtubeUrl)),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.subtle),
                  tooltip: 'Edit exercise',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  tooltip: 'Remove exercise',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
