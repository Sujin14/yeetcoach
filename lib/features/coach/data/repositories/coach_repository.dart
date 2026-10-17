import 'dart:io';
import '../../domain/entities/coach_profile.dart';
import '../../domain/repositories/i_coach_repository.dart';
import '../datasources/coach_storage_service.dart';
import '../datasources/firestore_coach_service.dart';

class CoachRepository implements ICoachRepository {
  final FirestoreCoachService _service;
  final CoachStorageService _storage;

  CoachRepository({FirestoreCoachService? service, CoachStorageService? storage})
      : _service = service ?? FirestoreCoachService(),
        _storage = storage ?? CoachStorageService();

  @override
  Future<CoachProfile?> getCoach(String uid) =>
      _service.getCoach(uid);

  @override
  Stream<CoachProfile?> watchCoach(String uid) =>
      _service.watchCoach(uid);

  @override
  Future<void> saveCoach(CoachProfile profile) =>
      _service.saveCoach(profile);

  @override
  Future<void> updateCoachFields(
          String uid, Map<String, dynamic> fields) =>
      _service.updateCoachFields(uid, fields);

  @override
  Future<void> mergeCoachFields(String uid, Map<String, dynamic> fields) =>
      _service.mergeCoachFields(uid, fields);

  @override
  Future<String> uploadProfilePhoto(String uid, File photo) =>
      _storage.uploadProfilePhoto(uid, photo);
}
