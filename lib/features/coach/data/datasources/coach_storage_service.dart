import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CoachStorageService {
  final FirebaseStorage _storage;

  CoachStorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  /// Same path onboarding uploads to, so the photo is replaced rather than duplicated.
  Future<String> uploadProfilePhoto(String uid, File photo) async {
    final ref = _storage.ref('coach_profiles/$uid/profile.jpg');
    await ref.putFile(photo, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
