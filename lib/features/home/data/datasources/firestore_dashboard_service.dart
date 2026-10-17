import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';
import 'package:yeetcoach/core/utils/weekday_label.dart';
import '../../domain/entities/recovery_level.dart';

/// Read-only lookups for the coach dashboard.
class FirestoreDashboardService {
  final FirebaseFirestore _firestore;

  FirestoreDashboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reads the client's copy of the coach's plans (users/{uid}/workouts), where
  /// exercises are flattened and each carries its day label in `day`.
  Future<String?> findWorkoutTitleForDay({
    required String clientUid,
    required String coachUid,
    required int weekday,
  }) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(clientUid)
        .collection(FirestoreCollections.userWorkouts)
        .where('assignedBy', isEqualTo: coachUid)
        .get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final details = data['details'];
      final exercises = details is Map ? details['exercises'] : null;
      if (exercises is! List) continue;
      final scheduledToday = exercises.whereType<Map>().any((exercise) {
        final day = exercise['day'];
        return day is String && labelMentionsWeekday(day, weekday);
      });
      if (scheduledToday) {
        final title = (data['title'] as String?)?.trim();
        return title == null || title.isEmpty ? 'Workout plan' : title;
      }
    }
    return null;
  }

  /// clients/{clientUid} snapshots. recoveryLevel wins when both fields are present.
  Stream<RecoveryLevel?> watchRecoveryLevel(String clientUid) {
    return _firestore.collection(FirestoreCollections.clients).doc(clientUid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return RecoveryLevel.tryParse(data['recoveryLevel']) ?? RecoveryLevel.tryParse(data['recoveryScore']);
    });
  }
}
