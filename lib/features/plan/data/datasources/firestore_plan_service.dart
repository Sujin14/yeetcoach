import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/diet_plan.dart';
import '../../domain/entities/workout_plan.dart';
import '../models/diet_plan_model.dart';
import '../models/workout_plan_model.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';

class FirestorePlanService {
  final FirebaseFirestore _firestore;

  FirestorePlanService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _plans => _firestore.collection(FirestoreCollections.plans);

  /// Requires a composite index on plans: clientUid ASC, type ASC, createdAt DESC.
  Query<Map<String, dynamic>> _clientPlansQuery(String clientUid, String type) {
    return _plans
        .where('clientUid', isEqualTo: clientUid)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true);
  }

  /// Requires a composite index on plans: clientUid ASC, trainerId ASC, type ASC, updatedAt DESC.
  Query<Map<String, dynamic>> _coachClientPlansQuery(String clientUid, String trainerId, String type) {
    return _plans
        .where('clientUid', isEqualTo: clientUid)
        .where('trainerId', isEqualTo: trainerId)
        .where('type', isEqualTo: type)
        .orderBy('updatedAt', descending: true);
  }

  Stream<List<WorkoutPlan>> watchWorkoutPlans(String clientUid, String trainerId) {
    return _coachClientPlansQuery(clientUid, trainerId, WorkoutPlanModel.planType).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => WorkoutPlanModel.fromMap(doc.data(), id: doc.id)).toList(),
        );
  }

  Stream<List<DietPlan>> watchDietPlans(String clientUid, String trainerId) {
    return _coachClientPlansQuery(clientUid, trainerId, DietPlanModel.planType).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => DietPlanModel.fromMap(doc.data(), id: doc.id)).toList(),
        );
  }

  Future<List<WorkoutPlan>> getWorkoutPlans(String clientUid) async {
    try {
      final snapshot = await _clientPlansQuery(clientUid, WorkoutPlanModel.planType).get();
      return snapshot.docs.map((doc) => WorkoutPlanModel.fromMap(doc.data(), id: doc.id)).toList();
    } catch (error, stackTrace) {
      _log('getWorkoutPlans($clientUid) failed', error, stackTrace);
      rethrow;
    }
  }

  Future<List<DietPlan>> getDietPlans(String clientUid) async {
    try {
      final snapshot = await _clientPlansQuery(clientUid, DietPlanModel.planType).get();
      return snapshot.docs.map((doc) => DietPlanModel.fromMap(doc.data(), id: doc.id)).toList();
    } catch (error, stackTrace) {
      _log('getDietPlans($clientUid) failed', error, stackTrace);
      rethrow;
    }
  }

  /// The client's copy at users/{clientUid}/{collection}/{planId}, which YeetFit reads.
  DocumentReference<Map<String, dynamic>> _clientPlanDoc(String clientUid, String collection, String planId) =>
      _firestore.collection(FirestoreCollections.users).doc(clientUid).collection(collection).doc(planId);

  String _clientCollectionFor(String planType) => switch (planType) {
        WorkoutPlanModel.planType => FirestoreCollections.userWorkouts,
        DietPlanModel.planType => FirestoreCollections.userDiets,
        _ => throw ArgumentError.value(planType, 'planType', 'must be workout or diet'),
      };

  Future<bool> saveWorkoutPlan(WorkoutPlan plan) async {
    try {
      final model = WorkoutPlanModel.fromEntity(plan);
      await _commitPlan(
        planId: plan.id,
        indexData: model.toMap(),
        clientDoc: _clientPlanDoc(plan.clientUid, FirestoreCollections.userWorkouts, plan.id),
        clientCreateData: model.toClientPlanMap(),
        clientUpdateData: model.toClientPlanUpdateMap(),
      );
      return true;
    } catch (error, stackTrace) {
      _log('saveWorkoutPlan(${plan.id}) failed', error, stackTrace);
      return false;
    }
  }

  Future<bool> saveDietPlan(DietPlan plan) async {
    try {
      final model = DietPlanModel.fromEntity(plan);
      await _commitPlan(
        planId: plan.id,
        indexData: model.toMap(),
        clientDoc: _clientPlanDoc(plan.clientUid, FirestoreCollections.userDiets, plan.id),
        clientCreateData: model.toClientPlanMap(),
        clientUpdateData: model.toClientPlanUpdateMap(),
      );
      return true;
    } catch (error, stackTrace) {
      _log('saveDietPlan(${plan.id}) failed', error, stackTrace);
      return false;
    }
  }

  /// Writes the coach-side index (full overwrite) and the client's copy atomically.
  /// An existing client copy is updated so the client's isFavorite and the original createdAt survive;
  /// a missing one (new plan, or a plan saved before the copy existed) is created in full.
  Future<void> _commitPlan({
    required String planId,
    required Map<String, dynamic> indexData,
    required DocumentReference<Map<String, dynamic>> clientDoc,
    required Map<String, dynamic> clientCreateData,
    required Map<String, dynamic> clientUpdateData,
  }) async {
    final clientCopyExists = (await clientDoc.get()).exists;
    final batch = _firestore.batch()..set(_plans.doc(planId), indexData, SetOptions(merge: false));
    if (clientCopyExists) {
      batch.update(clientDoc, clientUpdateData);
    } else {
      batch.set(clientDoc, clientCreateData, SetOptions(merge: false));
    }
    await batch.commit();
  }

  /// Deletes the coach-side index and the client's copy atomically. Throws on failure.
  Future<void> deletePlan(String planId, String clientUid, String planType) async {
    try {
      final batch = _firestore.batch()
        ..delete(_plans.doc(planId))
        ..delete(_clientPlanDoc(clientUid, _clientCollectionFor(planType), planId));
      await batch.commit();
    } catch (error, stackTrace) {
      _log('deletePlan($planId) failed', error, stackTrace);
      rethrow;
    }
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    logDebug('FirestorePlanService: $message - $error\n$stackTrace');
  }
}
