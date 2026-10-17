import '../../domain/entities/recovery_level.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
import '../datasources/firestore_dashboard_service.dart';

class DashboardRepository implements IDashboardRepository {
  final FirestoreDashboardService _service;

  DashboardRepository({FirestoreDashboardService? service})
      : _service = service ?? FirestoreDashboardService();

  @override
  Future<String?> findWorkoutTitleForDay({
    required String clientUid,
    required String coachUid,
    required int weekday,
  }) =>
      _service.findWorkoutTitleForDay(clientUid: clientUid, coachUid: coachUid, weekday: weekday);

  @override
  Stream<RecoveryLevel?> watchRecoveryLevel(String clientUid) =>
      _service.watchRecoveryLevel(clientUid);
}
