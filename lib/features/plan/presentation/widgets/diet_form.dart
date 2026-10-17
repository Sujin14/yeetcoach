import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/add_button.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/diet_plan_controller.dart';
import 'form_app_bar.dart';
import 'meal_card.dart';
import 'plan_header_fields.dart';
import 'section_label.dart';

class DietForm extends StatelessWidget {
  final DietPlanController ctrl;

  const DietForm({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: FormAppBar(
        title: ctrl.planId != null ? 'Edit Diet Plan' : 'New Diet Plan',
        isSaving: ctrl.isSaving,
        onSave: () => saveAndClose(context, ctrl.savePlan),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
            sliver: SliverList.list(
              children: [
                PlanHeaderFields(title: ctrl.title, description: ctrl.description),
                const SizedBox(height: AppSpacing.lg),
                const SectionLabel('Meals'),
                const SizedBox(height: AppSpacing.sm),
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: ctrl.meals
                          .asMap()
                          .entries
                          .map((entry) => MealCard(
                                key: ValueKey('meal-${entry.key}'),
                                mealIndex: entry.key,
                                meal: entry.value,
                                ctrl: ctrl,
                              ))
                          .toList(),
                    )),
                const SizedBox(height: AppSpacing.smd),
                AddButton('Add meal', () => ctrl.addMeal(null)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
