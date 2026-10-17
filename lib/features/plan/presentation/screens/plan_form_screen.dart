import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import '../../domain/entities/plan_type.dart';
import '../controllers/diet_plan_controller.dart';
import '../controllers/workout_plan_controller.dart';
import '../widgets/diet_form.dart';
import '../widgets/workout_form.dart';

class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key});

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  late final Widget _form;

  @override
  void initState() {
    super.initState();
    // Resolved once: Get.arguments points at the top-most route, so it changes while a
    // bottom sheet or dialog is open. PlanFormBinding has already run setupWithArguments.
    final args = (Get.arguments as Map?) ?? const {};
    final planType = switch (args) {
      {'type': PlanType type} => type,
      _ => PlanType.workout,
    };
    final uid = switch (args) {
      {'uid': String uid} => uid,
      _ => '',
    };
    final tag = AppRoutes.planControllerTag(uid, planType);

    _form = planType == PlanType.workout
        ? WorkoutForm(ctrl: Get.find<WorkoutPlanController>(tag: tag))
        : DietForm(ctrl: Get.find<DietPlanController>(tag: tag));
  }

  @override
  Widget build(BuildContext context) => _form;
}
