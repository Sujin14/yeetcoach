import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/add_button.dart';
import 'package:yeetcoach/core/widgets/confirmation_dialog.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/workout_plan.dart';
import '../controllers/workout_plan_controller.dart';
import 'editable_label.dart';
import 'exercise_card.dart';
import 'exercise_sheet.dart';
import 'expandable_card.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class WorkoutDayCard extends StatelessWidget {
  final int dayIndex;
  final WorkoutDay day;
  final WorkoutPlanController ctrl;

  const WorkoutDayCard({super.key, required this.dayIndex, required this.day, required this.ctrl});

  Future<void> _remove(BuildContext context) async {
    if (day.exercises.isNotEmpty) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Remove day?',
        message: '"${day.dayLabel}" and its ${day.exercises.length} exercise(s) will be removed.',
        confirmLabel: 'Remove',
      );
      if (!confirmed) return;
    }
    ctrl.removeDay(dayIndex);
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      // Expanded on create; on edit, only newly added (empty) days start open.
      initiallyExpanded: ctrl.planId == null || day.exercises.isEmpty,
      leading: ReorderableDragStartListener(
        index: dayIndex,
        child: const Icon(Icons.drag_handle, color: AppColors.subtle),
      ),
      title: EditableLabel(
        value: day.dayLabel,
        onChanged: (value) => ctrl.updateDayLabel(dayIndex, value),
        style: _textTheme.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      countLabel: '${day.exercises.length} ex',
      removeTooltip: 'Remove day',
      onRemove: () => _remove(context),
      children: [
        ...day.exercises.asMap().entries.map((entry) => ExerciseCard(
              key: ValueKey('ex-$dayIndex-${entry.key}'),
              exercise: entry.value,
              onEdit: () => showExerciseSheet(
                context,
                ctrl,
                dayIndex: dayIndex,
                exIndex: entry.key,
                existing: entry.value,
              ),
              onDelete: () => ctrl.removeExercise(dayIndex, entry.key),
            )),
        const SizedBox(height: AppSpacing.sm),
        AddButton('Add exercise', () => showExerciseSheet(context, ctrl, dayIndex: dayIndex)),
      ],
    );
  }
}
