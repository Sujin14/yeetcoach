import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_type.dart';
import '../models/challenge_model.dart';

class FirestoreChallengeService {
  /// Firestore's limit for `whereIn`.
  static const int _whereInLimit = 30;

  final FirebaseFirestore _db;

  FirestoreChallengeService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _challenges =>
      _db.collection(FirestoreCollections.challenges);

  /// Needs the composite index challenges(coachId ASC, createdAt DESC).
  Stream<List<Challenge>> watchCoachChallenges(String coachId) {
    return _challenges
        .where('coachId', isEqualTo: coachId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ChallengeModel.fromDoc).toList());
  }

  Stream<Challenge?> watchChallenge(String challengeId) {
    return _challenges
        .doc(challengeId)
        .snapshots()
        .map((doc) => doc.exists ? ChallengeModel.fromDoc(doc) : null);
  }

  Future<void> createChallenge({required String coachId, required NewChallenge challenge}) {
    return _challenges.add(ChallengeModel.createMap(coachId: coachId, challenge: challenge));
  }

  /// Security rules only let endDate move earlier, so it's left alone once it has passed.
  Future<void> endChallenge(Challenge challenge) {
    final now = DateTime.now();
    return _challenges.doc(challenge.id).update({
      'status': ChallengeStatus.ended.name,
      if (now.isBefore(challenge.endDate)) 'endDate': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, ChallengeMember>> getMembers(Iterable<String> uids) async {
    final ids = uids.where((uid) => uid.isNotEmpty).toSet().toList();
    final members = <String, ChallengeMember>{};
    for (var start = 0; start < ids.length; start += _whereInLimit) {
      final chunk = ids.sublist(start, (start + _whereInLimit).clamp(0, ids.length));
      try {
        final snapshot = await _db
            .collection(FirestoreCollections.users)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snapshot.docs) {
          members[doc.id] = _memberFromUser(doc.id, doc.data());
        }
      } catch (e) {
        logDebug('FirestoreChallengeService: loading members failed: $e');
      }
    }
    for (final uid in ids) {
      members.putIfAbsent(uid, () => ChallengeMember(uid: uid, name: 'Client', photoUrl: ''));
    }
    return members;
  }

  static ChallengeMember _memberFromUser(String uid, Map<String, dynamic> data) {
    final name = (data['name'] as String?)?.trim();
    return ChallengeMember(
      uid: uid,
      name: name == null || name.isEmpty ? 'Client' : name,
      photoUrl: (data['photoUrl'] as String?) ??
          (data['profileImageUrl'] as String?) ??
          (data['profilePicture'] as String?) ??
          '',
    );
  }
}
