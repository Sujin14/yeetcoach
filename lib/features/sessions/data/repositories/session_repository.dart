import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import '../../domain/entities/group_session.dart';
import '../models/group_session_model.dart';

class SessionRepository {
  SessionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  static const _meetHost = 'meet.google.com';

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection(FirestoreCollections.sessions);

  String get _uid => _auth.currentUser?.uid ?? '';

  /// Upcoming sessions for the signed-in coach, soonest first, including earlier today.
  Stream<List<GroupSession>> streamUpcoming() {
    if (_uid.isEmpty) return Stream.value(const []);
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _sessions
        .where('coachUid', isEqualTo: _uid)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .orderBy('scheduledAt')
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupSessionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<String> createSession({
    required String title,
    required String meetLink,
    required DateTime scheduledAt,
    required int durationMinutes,
    required bool isGlobal,
    required List<String> assignedClientUids,
    String? description,
  }) async {
    if (_uid.isEmpty) throw StateError('You must be logged in to schedule a session.');
    final trimmedTitle = title.trim();
    final trimmedLink = meetLink.trim();
    final trimmedDescription = description?.trim() ?? '';
    if (trimmedTitle.isEmpty) throw StateError('Enter a title.');
    if (!trimmedLink.toLowerCase().contains(_meetHost)) {
      throw StateError('Enter a valid Google Meet link.');
    }
    if (!scheduledAt.isAfter(DateTime.now())) {
      throw StateError('Choose a future date and time.');
    }
    final audience = isGlobal
        ? const <String>[]
        : assignedClientUids.map((uid) => uid.trim()).where((uid) => uid.isNotEmpty).toList();
    if (!isGlobal && audience.isEmpty) {
      throw StateError('Pick at least one client or make the session global.');
    }

    final ref = _sessions.doc();
    final coachDoc = await _db.collection(FirestoreCollections.coaches).doc(_uid).get();
    final coachData = coachDoc.data() ?? const <String, dynamic>{};
    final trainerName = (coachData['name'] as String?)?.trim() ?? 'Coach';
    final trainerPhoto = (coachData['profileImageUrl'] as String?)?.trim() ?? '';
    final session = GroupSessionModel(
      id: ref.id,
      coachUid: _uid,
      title: trimmedTitle,
      meetLink: trimmedLink,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      description: trimmedDescription.isEmpty ? null : trimmedDescription,
      createdAt: DateTime.now(),
      isGlobal: isGlobal,
      assignedClientUids: audience,
    );
    await ref.set(session.toMap(trainerName: trainerName, trainerPhoto: trainerPhoto));

    // Notifying clients must not roll back a session that is already saved.
    unawaited(
      _functions.httpsCallable('notifyNewSession').call({'sessionId': ref.id}).then<void>(
        (_) {},
        onError: (Object error, StackTrace _) {
          logDebug('SessionRepository: notifyNewSession failed: $error');
        },
      ),
    );
    return ref.id;
  }

  /// Deletes only when the signed-in coach owns the session.
  Future<void> deleteSession(String id) async {
    if (_uid.isEmpty) throw StateError('You must be logged in to delete a session.');
    final doc = await _sessions.doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) return;
    if (data['coachUid'] != _uid) {
      throw StateError('Only the coach who created this session can delete it.');
    }
    await doc.reference.delete();
  }
}
