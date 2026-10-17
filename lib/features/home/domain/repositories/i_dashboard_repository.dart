import '../entities/recovery_level.dart';

abstract class IDashboardRepository {
  /// Title of a workout plan [coachUid] assigned to the client with an exercise day
  /// labelled for [weekday], or null if there is none.
  Future<String?> findWorkoutTitleForDay({
    required String clientUid,
    required String coachUid,
    required int weekday,
  });

  /// Live clients/{clientUid} recovery. Prefers recoveryLevel, then recoveryScore.
  Stream<RecoveryLevel?> watchRecoveryLevel(String clientUid);
}
