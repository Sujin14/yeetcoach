import '../../domain/entities/assigned_workout_plan.dart';
import '../../domain/entities/client_recovery.dart';
import '../../domain/entities/client_relationship_info.dart';
import '../../domain/entities/daily_goal_metric.dart';
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/entities/recovery_day.dart';
import '../../domain/entities/workout_log_summary.dart';
import '../../domain/repositories/i_client_insights_repository.dart';
import '../datasources/firestore_client_insights_service.dart';

class ClientInsightsRepository implements IClientInsightsRepository {
  final FirestoreClientInsightsService _service;

  ClientInsightsRepository({FirestoreClientInsightsService? service})
      : _service = service ?? FirestoreClientInsightsService();

  @override
  Stream<ClientRecovery> watchRecovery(String clientUid) => _service.watchRecovery(clientUid);

  @override
  Stream<Map<String, RecoveryDay>> watchRecoveryRange(
    String clientUid,
    DateTime start,
    DateTime end,
  ) =>
      _service.watchRecoveryRange(clientUid, start, end);

  @override
  Stream<ClientRelationshipInfo?> watchRelationship({
    required String clientUid,
    required String coachUid,
  }) =>
      _service.watchRelationship(clientUid: clientUid, coachUid: coachUid);

  @override
  Stream<DailyGoalMetric?> watchDailyMetric(String clientUid, String date, DailyMetric metric) =>
      _service.watchDailyMetric(clientUid, date, metric);

  @override
  Stream<WorkoutLogSummary?> watchWorkoutLog(String clientUid, String date) =>
      _service.watchWorkoutLog(clientUid, date);

  @override
  Stream<NutritionSummary> watchNutrition(String clientUid, String date) =>
      _service.watchNutrition(clientUid, date);

  @override
  Future<int?> getDailyCalorieTarget(String clientUid) =>
      _service.getDailyCalorieTarget(clientUid);

  @override
  Stream<AssignedWorkoutPlan?> watchLatestWorkoutPlan(String clientUid) =>
      _service.watchLatestWorkoutPlan(clientUid);

  @override
  Stream<String> watchCoachNotes({required String clientUid, required String coachUid}) =>
      _service.watchCoachNotes(clientUid: clientUid, coachUid: coachUid);

  @override
  Future<void> saveCoachNotes({
    required String clientUid,
    required String coachUid,
    required String notes,
  }) =>
      _service.saveCoachNotes(clientUid: clientUid, coachUid: coachUid, notes: notes);
}
