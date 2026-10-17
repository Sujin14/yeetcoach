import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/add_button.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/workout_plan_controller.dart';
import 'form_app_bar.dart';
import 'plan_header_fields.dart';
import 'section_label.dart';
import 'workout_day_card.dart';

class WorkoutForm extends StatelessWidget {
  final WorkoutPlanController ctrl;

  const WorkoutForm({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: FormAppBar(
        title: ctrl.planId != null ? 'Edit Workout Plan' : 'New Workout Plan',
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
                const SectionLabel('Training Days'),
                const SizedBox(height: AppSpacing.sm),
                Obx(() {
                  final days = ctrl.days.toList();
                  return ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: days.length,
                    onReorderItem: ctrl.reorderDays,
                    proxyDecorator: (child, _, _) => Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    ),
                    itemBuilder: (_, index) => WorkoutDayCard(
                      key: ValueKey('day-$index'),
                      dayIndex: index,
                      day: days[index],
                      ctrl: ctrl,
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.smd),
                AddButton('Add training day', ctrl.addDay),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
