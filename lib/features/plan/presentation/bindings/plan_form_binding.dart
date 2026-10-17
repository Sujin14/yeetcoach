import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/features/plan/domain/entities/plan_type.dart';
import '../../data/datasources/firestore_plan_service.dart';
import '../../data/repositories/plan_repository_impl.dart';
import '../controllers/diet_plan_controller.dart';
import '../controllers/workout_plan_controller.dart';

class PlanFormBinding extends Bindings {
  @override
  void dependencies() {
    // Captured now: Get.arguments changes while dialogs or sheets are open on the form.
    final args = (Get.arguments as Map?) ?? const {};
    final type = switch (args) {
      {'type': PlanType type} => type,
      _ => PlanType.workout,
    };
    final uid = switch (args) {
      {'uid': String uid} => uid,
      _ => '',
    };
    final tag = AppRoutes.planControllerTag(uid, type);
    final repository = PlanRepositoryImpl(FirestorePlanService());

    // lazyPut ignores a registration that already exists, so drop any leftover form state first.
    if (type == PlanType.workout) {
      if (Get.isRegistered<WorkoutPlanController>(tag: tag)) {
        Get.delete<WorkoutPlanController>(tag: tag, force: true);
      }
      Get.lazyPut<WorkoutPlanController>(
        () => WorkoutPlanController(repository)..setupWithArguments(args),
        tag: tag,
      );
    } else {
      if (Get.isRegistered<DietPlanController>(tag: tag)) {
        Get.delete<DietPlanController>(tag: tag, force: true);
      }
      Get.lazyPut<DietPlanController>(
        () => DietPlanController(repository)..setupWithArguments(args),
        tag: tag,
      );
    }
  }
}
