import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/count_up_text.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/client_detail_controller.dart';
import 'client_detail_section_shimmers.dart';
import 'client_section.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class NutritionTodayCard extends GetView<ClientDetailController> {
  const NutritionTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSectionLoading(ClientDetailSection.nutrition)) {
        return const NutritionCardShimmer();
      }
      final nutrition = controller.nutrition.value;
      if (!nutrition.hasEntries) {
        return ClientCard(
          child: Row(
            children: [
              const Icon(Icons.restaurant_outlined, color: AppColors.statusNone, size: 22),
              const SizedBox(width: AppSpacing.smd),
              Text(
                'No meals logged today',
                style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
              ),
            ],
          ),
        );
      }

      final numbers = NumberFormat.decimalPattern();
      final target = controller.calorieTarget.value;
      final calories = nutrition.calories.round();
      return ClientCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                CountUpText(
                  value: calories.toDouble(),
                  format: (current) => numbers.format(current.round()),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  target == null ? 'kcal' : '/ ${numbers.format(target)} kcal',
                  style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
                ),
              ],
            ),
            Text(
              target == null ? 'No daily calorie target set' : 'Calories logged today',
              style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
            ),
            if (target != null) ...[
              const SizedBox(height: AppSpacing.smd),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (calories / target).clamp(0.0, 1.0),
                  minHeight: 8,
                  color: AppColors.primary,
                  backgroundColor: AppColors.divider,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.smd),
            Text(
              'Protein ${nutrition.protein.round()}g · '
              'Carbs ${nutrition.carbs.round()}g · '
              'Fat ${nutrition.fat.round()}g',
              style: _textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      );
    });
  }
}
