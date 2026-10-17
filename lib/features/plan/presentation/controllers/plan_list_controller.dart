import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/plan/domain/entities/diet_plan.dart';
import 'package:yeetcoach/features/plan/domain/entities/plan_type.dart';
import 'package:yeetcoach/features/plan/domain/entities/workout_plan.dart';
import 'package:yeetcoach/features/plan/domain/repositories/plan_repository.dart';

class PlanListController extends GetxController {
  final PlanRepository _repository;
  final FirebaseAuth _auth;

  PlanListController(this._repository, {FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final RxList<WorkoutPlan> workoutPlans = <WorkoutPlan>[].obs;
  final RxList<DietPlan> dietPlans = <DietPlan>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isDeleting = false.obs;

  late final String clientUid;
  late final PlanType planType;
  late final String coachUid;

  StreamSubscription<Object?>? _sub;

  bool get isWorkout => planType == PlanType.workout;

  /// The [WorkoutPlan]s or [DietPlan]s for [planType].
  List<Object> get plans => isWorkout ? workoutPlans : dietPlans;

  @override
  void onInit() {
    super.onInit();
    // Pattern match so missing or wrongly typed values fall back instead of throwing.
    final args = Get.arguments;
    clientUid = switch (args) {
      {'uid': String uid} => uid,
      _ => '',
    };
    planType = switch (args) {
      {'type': PlanType type} => type,
      _ => PlanType.workout,
    };
    coachUid = _auth.currentUser?.uid ?? '';

    if (clientUid.isEmpty || coachUid.isEmpty) {
      isLoading.value = false;
      logDebug('PlanListController: missing uid or not logged in');
      return;
    }
    _subscribe();
  }

  void _subscribe() {
    void onError(Object error) {
      logDebug('PlanListController: plan stream error: $error');
      isLoading.value = false;
      showErrorSnackbar('Could not load plans. Please try again.');
    }

    _sub = isWorkout
        ? _repository.watchWorkoutPlans(clientUid, coachUid).listen(
            (list) {
              workoutPlans.assignAll(list);
              isLoading.value = false;
            },
            onError: onError,
          )
        : _repository.watchDietPlans(clientUid, coachUid).listen(
            (list) {
              dietPlans.assignAll(list);
              isLoading.value = false;
            },
            onError: onError,
          );
  }

  void openCreateForm() {
    Get.toNamed(
      AppRoutes.planForm,
      arguments: {'uid': clientUid, 'type': planType},
    );
  }

  /// The plan form enters edit mode only when it receives the plan object itself.
  void openEditForm(Object plan) {
    Get.toNamed(
      AppRoutes.planForm,
      arguments: {'uid': clientUid, 'type': planType, 'plan': plan},
    );
  }

  Future<void> deletePlan(String planId) async {
    if (isDeleting.value) return;
    isDeleting.value = true;
    try {
      await _repository.deletePlan(planId, clientUid, planType.value);
      showSuccessSnackbar('Plan deleted.');
    } catch (e) {
      logDebug('PlanListController: delete failed: $e');
      showErrorSnackbar('Could not delete plan. Please try again.');
    } finally {
      isDeleting.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
