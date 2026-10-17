import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/add_button.dart';
import 'package:yeetcoach/core/widgets/confirmation_dialog.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/diet_plan.dart';
import '../controllers/diet_plan_controller.dart';
import 'editable_label.dart';
import 'expandable_card.dart';
import 'food_item_card.dart';
import 'food_sheet.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class MealCard extends StatelessWidget {
  final int mealIndex;
  final MealEntry meal;
  final DietPlanController ctrl;

  const MealCard({super.key, required this.mealIndex, required this.meal, required this.ctrl});

  Future<void> _remove(BuildContext context) async {
    if (meal.foods.isNotEmpty) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Remove meal?',
        message: '"${meal.mealName}" and its ${meal.foods.length} food item(s) will be removed.',
        confirmLabel: 'Remove',
      );
      if (!confirmed) return;
    }
    ctrl.removeMeal(mealIndex);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && context.mounted) ctrl.updateMeal(mealIndex, time: picked.format(context));
  }

  @override
  Widget build(BuildContext context) {
    final subtleSmall = _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle);

    return ExpandableCard(
      initiallyExpanded: ctrl.planId == null || meal.foods.isEmpty,
      title: EditableLabel(
        value: meal.mealName,
        onChanged: (value) => ctrl.updateMeal(mealIndex, mealName: value),
        style: _textTheme.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(meal.time.isEmpty ? 'No time set' : meal.time, style: subtleSmall),
      countLabel: '${meal.foods.length} foods',
      removeTooltip: 'Remove meal',
      onRemove: () => _remove(context),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pickTime(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 16, color: AppColors.subtle),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  meal.time.isEmpty ? 'Set meal time' : meal.time,
                  style: _textTheme.bodySmall?.copyWith(fontSize: 13, color: AppColors.subtle),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...meal.foods.asMap().entries.map((entry) => FoodItemCard(
              key: ValueKey('food-$mealIndex-${entry.key}'),
              food: entry.value,
              onDelete: () => ctrl.removeFood(mealIndex, entry.key),
            )),
        const SizedBox(height: AppSpacing.sm),
        AddButton('Add food', () => showFoodSheet(context, ctrl, mealIndex)),
      ],
    );
  }
}
