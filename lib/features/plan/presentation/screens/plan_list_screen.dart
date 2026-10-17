import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/shimmers/plan_list_shimmer.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/diet_plan.dart';
import '../../domain/entities/workout_plan.dart';
import '../controllers/plan_list_controller.dart';
import '../widgets/plan_card.dart';
import '../widgets/plan_empty_state.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

String _plural(int count, String noun) => '$count $noun${count == 1 ? '' : 's'}';

PlanSummary _summaryOf(Object plan) => switch (plan) {
      WorkoutPlan p => (
          id: p.id,
          title: p.title,
          description: p.description,
          updatedAt: p.updatedAt,
          countLabel: _plural(p.days.length, 'day'),
          plan: p,
        ),
      DietPlan p => (
          id: p.id,
          title: p.title,
          description: p.description,
          updatedAt: p.updatedAt,
          countLabel: _plural(p.meals.length, 'meal'),
          plan: p,
        ),
      _ => throw ArgumentError('Unsupported plan type: ${plan.runtimeType}'),
    };

class PlanListScreen extends GetView<PlanListController> {
  const PlanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWorkout = controller.isWorkout;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          tooltip: 'Back',
          onPressed: Get.back,
        ),
        title: Text(
          isWorkout ? 'Workout Plans' : 'Diet Plans',
          style: _textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const PlanListShimmer();

        final plans = controller.plans.map(_summaryOf).toList();
        if (plans.isEmpty) return PlanEmptyState(isWorkout: isWorkout);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
          itemCount: plans.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.smd),
          itemBuilder: (_, index) => PlanCard(summary: plans[index], controller: controller),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(
          isWorkout ? 'New Workout Plan' : 'New Diet Plan',
          style: _textTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onPressed: controller.openCreateForm,
      ),
    );
  }
}
