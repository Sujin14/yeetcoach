import 'dart:io';
import '../entities/coach_profile.dart';

abstract class ICoachRepository {
  /// Returns null if the document does not exist.
  Future<CoachProfile?> getCoach(String uid);

  /// Emits null when the document is deleted.
  Stream<CoachProfile?> watchCoach(String uid);

  /// Writes every field; use only for full profile saves.
  Future<void> saveCoach(CoachProfile profile);

  /// Partial update — supply only the fields to change.
  Future<void> updateCoachFields(
      String uid, Map<String, dynamic> fields);

  /// Merge write of editable profile fields; name and photo are mirrored to users/{uid}.
  Future<void> mergeCoachFields(String uid, Map<String, dynamic> fields);

  /// Uploads the profile photo and returns its download URL.
  Future<String> uploadProfilePhoto(String uid, File photo);
}
