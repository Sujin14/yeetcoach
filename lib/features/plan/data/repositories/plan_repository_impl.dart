import '../../domain/entities/diet_plan.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/firestore_plan_service.dart';

class PlanRepositoryImpl implements PlanRepository {
  final FirestorePlanService _service;

  PlanRepositoryImpl(this._service);

  @override
  Future<List<WorkoutPlan>> getWorkoutPlans(String clientUid) => _service.getWorkoutPlans(clientUid);

  @override
  Future<List<DietPlan>> getDietPlans(String clientUid) => _service.getDietPlans(clientUid);

  @override
  Stream<List<WorkoutPlan>> watchWorkoutPlans(String clientUid, String trainerId) =>
      _service.watchWorkoutPlans(clientUid, trainerId);

  @override
  Stream<List<DietPlan>> watchDietPlans(String clientUid, String trainerId) =>
      _service.watchDietPlans(clientUid, trainerId);

  @override
  Future<bool> saveWorkoutPlan(WorkoutPlan plan) => _service.saveWorkoutPlan(plan);

  @override
  Future<bool> saveDietPlan(DietPlan plan) => _service.saveDietPlan(plan);

  @override
  Future<void> deletePlan(String planId, String clientUid, String planType) =>
      _service.deletePlan(planId, clientUid, planType);
}
