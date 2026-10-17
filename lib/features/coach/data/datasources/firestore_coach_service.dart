import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import '../../domain/entities/coach_profile.dart';
import '../models/coach_profile_model.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';

class FirestoreCoachService {
  final FirebaseFirestore _db;
  FirestoreCoachService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _coaches =>
      _db.collection(FirestoreCollections.coaches);

  Future<CoachProfile?> getCoach(String uid) async {
    try {
      final doc = await _coaches.doc(uid).get();
      if (!doc.exists) return null;
      return CoachProfileModel.fromDoc(doc);
    } catch (e) {
      logDebug('FirestoreCoachService.getCoach error: $e');
      rethrow;
    }
  }

  Stream<CoachProfile?> watchCoach(String uid) {
    return _coaches.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CoachProfileModel.fromDoc(doc);
    });
  }

  Future<void> saveCoach(CoachProfile profile) async {
    final model = CoachProfileModel(
      uid: profile.uid,
      name: profile.name,
      email: profile.email,
      profileImageUrl: profile.profileImageUrl,
      bio: profile.bio,
      specializations: profile.specializations,
      certifications: profile.certifications,
      isVerified: profile.isVerified,
      isActive: profile.isActive,
      averageRating: profile.averageRating,
      totalClients: profile.totalClients,
      experienceYears: profile.experienceYears,
      phoneNumber: profile.phoneNumber,
      createdAt: profile.createdAt,
      updatedAt: DateTime.now(),
    );
    final map = model.toMap();
    // updatedAt comes from the server clock, not the device clock.
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _coaches.doc(profile.uid).set(map, SetOptions(merge: false));
  }

  /// Merge-writes [fields] to coaches/{uid}. A changed name or photo is mirrored onto
  /// users/{uid} in the same batch, as onboarding does, so YeetFit shows it too.
  Future<void> mergeCoachFields(String uid, Map<String, dynamic> fields) async {
    final batch = _db.batch()
      ..set(
        _coaches.doc(uid),
        {...fields, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    final name = fields['name'];
    final photoUrl = fields['profileImageUrl'];
    if (name is String || photoUrl is String) {
      batch.set(
        _db.collection(FirestoreCollections.users).doc(uid),
        {
          if (name is String) 'name': name,
          if (photoUrl is String) 'profilePicture': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> updateCoachFields(
      String uid, Map<String, dynamic> fields) async {
    await _coaches.doc(uid).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
