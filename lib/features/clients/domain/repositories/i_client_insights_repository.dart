import '../entities/assigned_workout_plan.dart';
import '../entities/client_recovery.dart';
import '../entities/client_relationship_info.dart';
import '../entities/daily_goal_metric.dart';
import '../entities/nutrition_summary.dart';
import '../entities/workout_log_summary.dart';

enum DailyMetric { sleep, water, steps }

/// Thrown on a stream when the client's data exists but the coach isn't allowed to read it.
class RestrictedClientDataException implements Exception {
  const RestrictedClientDataException();

  @override
  String toString() => 'RestrictedClientDataException';
}

/// Read-mostly view of a client's health data for the client details screen.
/// Dates are 'yyyy-MM-dd' day keys, as written by YeetFit.
abstract class IClientInsightsRepository {
  Stream<ClientRecovery> watchRecovery(String clientUid);

  /// Null when there is no relationship document between the two.
  Stream<ClientRelationshipInfo?> watchRelationship({
    required String clientUid,
    required String coachUid,
  });

  /// Null when nothing was logged for [date].
  Stream<DailyGoalMetric?> watchDailyMetric(String clientUid, String date, DailyMetric metric);

  /// Null when no workout was logged for [date]. Errors with
  /// [RestrictedClientDataException] when the coach can't read workout logs.
  Stream<WorkoutLogSummary?> watchWorkoutLog(String clientUid, String date);

  Stream<NutritionSummary> watchNutrition(String clientUid, String date);

  /// users/{uid}.dailyCalorieTarget, or null when the client hasn't set one.
  Future<int?> getDailyCalorieTarget(String clientUid);

  Stream<AssignedWorkoutPlan?> watchLatestWorkoutPlan(String clientUid);

  /// The coach's private note from coaches/{coachUid}/client_notes/{clientUid};
  /// empty when none has been written.
  Stream<String> watchCoachNotes({required String clientUid, required String coachUid});

  Future<void> saveCoachNotes({
    required String clientUid,
    required String coachUid,
    required String notes,
  });
}
