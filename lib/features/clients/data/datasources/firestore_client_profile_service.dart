import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import '../../domain/entities/client_profile.dart';
import '../models/client_profile_model.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';

class FirestoreClientProfileService {
  final FirebaseFirestore _db;
  FirestoreClientProfileService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clients =>
      _db.collection(FirestoreCollections.clients);

  Future<ClientProfile?> getClient(String uid) async {
    try {
      final doc = await _clients.doc(uid).get();
      if (!doc.exists) return null;
      return await _withUserIdentity(ClientProfileModel.fromDoc(doc));
    } catch (e) {
      logDebug('FirestoreClientProfileService.getClient error: $e');
      rethrow;
    }
  }

  Stream<ClientProfile?> watchClient(String uid) {
    return _clients.doc(uid).snapshots().asyncMap((doc) async {
      if (!doc.exists) return null;
      return _withUserIdentity(ClientProfileModel.fromDoc(doc));
    });
  }

  Stream<List<ClientProfile>> watchCoachClients(String coachId) {
    return _clients.where('currentCoachId', isEqualTo: coachId).snapshots().asyncMap(
          (snap) => Future.wait(snap.docs.map((doc) => _withUserIdentity(ClientProfileModel.fromDoc(doc)))),
        );
  }

  /// Separate from [watchCoachClients] so the dashboard does not load every client to filter today.
  Stream<List<ClientProfile>> watchTodaysClients(String coachUid) {
    // Requires Firestore composite index: clients — currentCoachId ASC + trainingDays ASC
    return _clients
        .where('currentCoachId', isEqualTo: coachUid)
        .where('trainingDays', arrayContains: DateTime.now().weekday)
        .snapshots()
        .asyncMap(
          (snap) => Future.wait(snap.docs.map((doc) => _withUserIdentity(ClientProfileModel.fromDoc(doc)))),
        );
  }

  /// YeetFit keeps the photo on users/{uid}.profilePicture and the fitness goal
  /// on users/{uid}.goal. The clients mirror only copies name and photo.
  Future<ClientProfile> _withUserIdentity(ClientProfile profile) async {
    final hasPhoto = profile.profileImageUrl?.trim().isNotEmpty ?? false;
    final hasName = profile.name.trim().isNotEmpty;
    final hasGoal = profile.primaryGoal?.trim().isNotEmpty ?? false;
    if (hasPhoto && hasName && hasGoal) return profile;
    try {
      final data = (await _db.collection(FirestoreCollections.users).doc(profile.uid).get()).data();
      final photo = _optionalString(data?['profileImageUrl']) ?? _optionalString(data?['profilePicture']);
      final userName = _optionalString(data?['name']);
      final goal = _optionalString(data?['goal']);
      return profile.copyWith(
        profileImageUrl: hasPhoto ? profile.profileImageUrl : photo,
        name: (!hasName && userName != null) ? userName : null,
        primaryGoal: hasGoal ? profile.primaryGoal : goal,
      );
    } catch (e) {
      logDebug('FirestoreClientProfileService: loading users/${profile.uid} failed: $e');
      return profile;
    }
  }

  String? _optionalString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> createClient(ClientProfile profile) async {
    final map = _toModel(profile).toMap();
    map['createdAt'] = FieldValue.serverTimestamp();
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _clients.doc(profile.uid).set(map);
  }

  Future<void> updateTrainingDays(String clientUid, List<int> days) async {
    await _clients.doc(clientUid).update({
      'trainingDays': days,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateClient(ClientProfile profile) async {
    final map = _toModel(profile).toMap();
    map['updatedAt'] = FieldValue.serverTimestamp();
    // createdAt must not be overwritten on updates
    map.remove('createdAt');
    await _clients.doc(profile.uid).update(map);
  }

  @Deprecated(
    'Use TrainingRepository.endRelationship — it clears currentCoachId '
    'atomically. Only call this directly for admin/account-deletion flows.',
  )
  Future<void> clearCoachId(String clientUid) async {
    await _clients.doc(clientUid).update({
      'currentCoachId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  ClientProfileModel _toModel(ClientProfile profile) => ClientProfileModel(
        uid: profile.uid,
        name: profile.name,
        email: profile.email,
        profileImageUrl: profile.profileImageUrl,
        age: profile.age,
        gender: profile.gender,
        heightCm: profile.heightCm,
        weightKg: profile.weightKg,
        targetWeightKg: profile.targetWeightKg,
        medicalConditions: profile.medicalConditions,
        injuries: profile.injuries,
        medications: profile.medications,
        fitnessLevel: profile.fitnessLevel,
        yearsTraining: profile.yearsTraining,
        activityLevel: profile.activityLevel,
        availableEquipment: profile.availableEquipment,
        trainingDaysPerWeek: profile.trainingDaysPerWeek,
        trainingDays: profile.trainingDays,
        preferredTrainingTime: profile.preferredTrainingTime,
        primaryGoal: profile.primaryGoal,
        targetDate: profile.targetDate,
        foodPreference: profile.foodPreference,
        foodAllergies: profile.foodAllergies,
        currentCoachId: profile.currentCoachId,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      );
}
