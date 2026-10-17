import '../entities/diet_plan.dart';
import '../entities/workout_plan.dart';

abstract class PlanRepository {
  Future<List<WorkoutPlan>> getWorkoutPlans(String clientUid);
  Future<List<DietPlan>> getDietPlans(String clientUid);

  /// Live plans this trainer wrote for this client, most recently updated first.
  Stream<List<WorkoutPlan>> watchWorkoutPlans(String clientUid, String trainerId);
  Stream<List<DietPlan>> watchDietPlans(String clientUid, String trainerId);

  Future<bool> saveWorkoutPlan(WorkoutPlan plan);
  Future<bool> saveDietPlan(DietPlan plan);

  /// Removes plans/{planId} and the client's copy together. [planType] is 'workout' or 'diet'.
  /// Throws on failure.
  Future<void> deletePlan(String planId, String clientUid, String planType);
}
