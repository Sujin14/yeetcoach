import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/features/home/domain/entities/recovery_level.dart';
import '../../domain/entities/assigned_workout_plan.dart';
import '../../domain/entities/client_recovery.dart';
import '../../domain/entities/client_relationship_info.dart';
import '../../domain/entities/daily_goal_metric.dart';
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/entities/recovery_day.dart';
import '../../domain/entities/workout_log_summary.dart';
import '../../domain/repositories/i_client_insights_repository.dart';

/// Reads the YeetFit-owned health data of a client. Field names and defaults
/// mirror YeetFit's daily progress provider.
class FirestoreClientInsightsService {
  final FirebaseFirestore _db;

  FirestoreClientInsightsService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection(FirestoreCollections.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _progress(String uid, String metric) =>
      _user(uid).collection(FirestoreCollections.userProgress).doc(metric).collection(metric);

  DocumentReference<Map<String, dynamic>> _relationship(String clientUid, String coachUid) => _db
      .collection(FirestoreCollections.trainingRelationships)
      .doc('${clientUid}_$coachUid');

  Stream<ClientRecovery> watchRecovery(String clientUid) {
    return _db.collection(FirestoreCollections.clients).doc(clientUid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return ClientRecovery.empty;
      final score = (data['recoveryScore'] as num?)?.toInt();
      return ClientRecovery(
        score: score?.clamp(0, 100),
        level: RecoveryLevel.tryParse(data['recoveryLevel']) ?? RecoveryLevel.tryParse(score),
        updatedAt: _toDateTime(data['recoveryUpdatedAt']),
      );
    });
  }

  /// users/{clientUid}/recovery docs with `date` in [start, end] (local calendar days).
  Stream<Map<String, RecoveryDay>> watchRecoveryRange(
    String clientUid,
    DateTime start,
    DateTime end,
  ) {
    final startKey = DateFormat('yyyy-MM-dd').format(DateTime(start.year, start.month, start.day));
    final endKey = DateFormat('yyyy-MM-dd').format(DateTime(end.year, end.month, end.day));
    return _user(clientUid)
        .collection(FirestoreCollections.userRecovery)
        .where('date', isGreaterThanOrEqualTo: startKey)
        .where('date', isLessThanOrEqualTo: endKey)
        .snapshots()
        .map(_parseRecoveryRange)
        .transform(
          StreamTransformer<Map<String, RecoveryDay>, Map<String, RecoveryDay>>.fromHandlers(
            handleError: (error, stackTrace, sink) {
              logDebug('FirestoreClientInsightsService: watchRecoveryRange failed: $error');
              sink.add(const {});
            },
          ),
        );
  }

  static Map<String, RecoveryDay> _parseRecoveryRange(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final days = <String, RecoveryDay>{};
    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final key = data['date'] as String? ?? doc.id;
        final parsed = DateTime.tryParse(key);
        if (parsed == null) continue;
        final rawScore = (data['score'] as num?)?.toInt();
        if (rawScore == null) continue;
        final score = rawScore.clamp(0, 100);
        final level = RecoveryLevel.tryParse(data['level']) ?? RecoveryLevel.tryParse(score);
        days[key] = RecoveryDay(
          date: DateTime(parsed.year, parsed.month, parsed.day),
          score: score,
          level: level,
        );
      } catch (e) {
        logDebug('FirestoreClientInsightsService: skip recovery doc ${doc.id}: $e');
      }
    }
    return days;
  }

  Stream<ClientRelationshipInfo?> watchRelationship({
    required String clientUid,
    required String coachUid,
  }) {
    return _relationship(clientUid, coachUid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return ClientRelationshipInfo(
        id: doc.id,
        // acceptedAt isn't written on accept, so the accept-time updatedAt stands in for it.
        trainingSince: _toDateTime(data['acceptedAt']) ??
            _toDateTime(data['updatedAt']) ??
            _toDateTime(data['requestedAt']),
      );
    });
  }

  DocumentReference<Map<String, dynamic>> _coachNote(String clientUid, String coachUid) => _db
      .collection(FirestoreCollections.coaches)
      .doc(coachUid)
      .collection(FirestoreCollections.coachClientNotes)
      .doc(clientUid);

  /// Empty string when the coach hasn't written a note yet.
  Stream<String> watchCoachNotes({required String clientUid, required String coachUid}) {
    return _coachNote(clientUid, coachUid)
        .snapshots()
        .map((doc) => doc.data()?['notes'] as String? ?? '');
  }

  Stream<DailyGoalMetric?> watchDailyMetric(String clientUid, String date, DailyMetric metric) {
    final (collection, valueField, goalField, defaultGoal) = switch (metric) {
      DailyMetric.sleep => (FirestoreCollections.progressSleep, 'duration', 'goalHours', 8.0),
      DailyMetric.water =>
        (FirestoreCollections.progressWater, 'glassesConsumed', 'goalGlasses', 8.0),
      DailyMetric.steps => (FirestoreCollections.progressSteps, 'steps', 'goalSteps', 10000.0),
    };
    return _progress(clientUid, collection).doc(date).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return DailyGoalMetric(
        value: _toDouble(data[valueField]) ?? 0,
        goal: _toDouble(data[goalField]) ?? defaultGoal,
      );
    });
  }

  Stream<WorkoutLogSummary?> watchWorkoutLog(String clientUid, String date) {
    return _progress(clientUid, FirestoreCollections.progressWorkout)
        .doc(date)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (data == null) return null;
          return WorkoutLogSummary(
            type: data['type'] as String? ?? '',
            durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 0,
            intensity: data['intensity'] as String? ?? '',
            fromPlan: data['fromPlan'] as bool? ?? false,
          );
        })
        .transform(_restrictedOnPermissionDenied());
  }

  Stream<NutritionSummary> watchNutrition(String clientUid, String date) {
    return _progress(clientUid, FirestoreCollections.progressFood)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) {
          var calories = 0.0, protein = 0.0, carbs = 0.0, fat = 0.0;
          var count = 0;
          for (final doc in snapshot.docs) {
            // Legacy per-day goal documents share the date field.
            if (doc.id == '$date-goal') continue;
            final data = doc.data();
            calories += _toDouble(data['calories']) ?? 0;
            protein += _toDouble(data['protein']) ?? 0;
            carbs += _toDouble(data['carbs']) ?? 0;
            fat += _toDouble(data['fat']) ?? 0;
            count++;
          }
          return NutritionSummary(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            entryCount: count,
          );
        });
  }

  Future<int?> getDailyCalorieTarget(String clientUid) async {
    final doc = await _user(clientUid).get();
    final target = _toDouble(doc.data()?['dailyCalorieTarget']);
    return target == null || target <= 0 ? null : target.round();
  }

  /// Single-field ordering, so no composite index is needed.
  Stream<AssignedWorkoutPlan?> watchLatestWorkoutPlan(String clientUid) {
    return _user(clientUid)
        .collection(FirestoreCollections.userWorkouts)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          final data = doc.data();
          final details = data['details'];
          final rawExercises = details is Map ? details['exercises'] : null;
          return AssignedWorkoutPlan(
            id: doc.id,
            title: (data['title'] as String?)?.trim() ?? '',
            createdAt: _toDateTime(data['createdAt']),
            exercises: [
              if (rawExercises is List)
                for (final exercise in rawExercises.whereType<Map>())
                  AssignedExercise(
                    name: exercise['name']?.toString() ?? '',
                    day: exercise['day']?.toString() ?? '',
                    sets: (exercise['sets'] as num?)?.toInt(),
                    reps: (exercise['reps'] as num?)?.toInt(),
                    repsType: exercise['repsType']?.toString() ?? '',
                  ),
            ],
          );
        });
  }

  Future<void> saveCoachNotes({
    required String clientUid,
    required String coachUid,
    required String notes,
  }) {
    return _coachNote(clientUid, coachUid).set(
      {'notes': notes, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  static StreamTransformer<T, T> _restrictedOnPermissionDenied<T>() {
    return StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stackTrace, sink) {
        if (error is FirebaseException && error.code == 'permission-denied') {
          sink.addError(const RestrictedClientDataException(), stackTrace);
        } else {
          sink.addError(error, stackTrace);
        }
      },
    );
  }

  static DateTime? _toDateTime(Object? value) => switch (value) {
        Timestamp() => value.toDate(),
        DateTime() => value,
        String() => DateTime.tryParse(value),
        _ => null,
      };

  static double? _toDouble(Object? value) => switch (value) {
        num() => value.toDouble(),
        String() => double.tryParse(value),
        _ => null,
      };
}
