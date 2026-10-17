import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import '../../domain/entities/training_relationship.dart';
import '../models/training_relationship_model.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';

class FirestoreTrainingService {
  final FirebaseFirestore _db;
  final Uuid _uuid;

  FirestoreTrainingService({FirebaseFirestore? db, Uuid? uuid})
      : _db = db ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  CollectionReference<Map<String, dynamic>> get _relationships =>
      _db.collection(FirestoreCollections.trainingRelationships);

  Future<TrainingRelationship?> getRelationship(String id) async {
    try {
      final doc = await _relationships.doc(id).get();
      if (!doc.exists) return null;
      return TrainingRelationshipModel.fromDoc(doc);
    } catch (e) {
      logDebug('FirestoreTrainingService.getRelationship error: $e');
      rethrow;
    }
  }

  /// Requires a composite index on training_relationships: coachId ASC, status ASC, requestedAt DESC.
  Stream<List<TrainingRelationship>> watchPendingRequests(
      String coachId) {
    return _relationships
        .where('coachId', isEqualTo: coachId)
        .where('status', isEqualTo: RelationshipStatus.pending.name)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .asyncMap(_withClientDetails);
  }

  Stream<List<TrainingRelationship>> watchActiveRelationships(
      String coachId) {
    return _relationships
        .where('coachId', isEqualTo: coachId)
        .where('status', isEqualTo: RelationshipStatus.active.name)
        .snapshots()
        .asyncMap(_withClientDetails);
  }

  /// Requests this coach accepted (now active) or declined, most recently decided first.
  /// Sorted and trimmed on device so no extra composite index is needed.
  Stream<List<TrainingRelationship>> watchRecentDecisions(String coachId, {int limit = 10}) {
    return _relationships
        .where('coachId', isEqualTo: coachId)
        .where('status', whereIn: [
          RelationshipStatus.active.name,
          RelationshipStatus.declined.name,
          'rejected',
        ])
        .snapshots()
        .map((snap) {
          final decided = [
            for (final doc in snap.docs)
              (doc: doc, at: _decidedAt(TrainingRelationshipModel.fromDoc(doc))),
          ]..sort((a, b) => b.at.compareTo(a.at));
          return [for (final entry in decided.take(limit)) entry.doc];
        })
        .asyncMap(_withClientDetailsFromDocs);
  }

  static DateTime _decidedAt(TrainingRelationship relationship) =>
      relationship.updatedAt ?? relationship.acceptedAt ?? relationship.requestedAt;

  /// Keyed by client uid, for the lifetime of this service.
  final Map<String, ({String name, String photoUrl})> _clientDetailsCache = {};

  Future<List<TrainingRelationship>> _withClientDetails(
          QuerySnapshot<Map<String, dynamic>> snap) =>
      _withClientDetailsFromDocs(snap.docs);

  Future<List<TrainingRelationship>> _withClientDetailsFromDocs(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return Future.wait(docs.map((doc) async {
      final relationship = TrainingRelationshipModel.fromDoc(doc);
      if (relationship.clientName.isNotEmpty) return relationship;
      final details = await _clientDetails(relationship.clientUid);
      return relationship.copyWith(clientName: details.name, clientPhoto: details.photoUrl);
    }));
  }

  /// YeetFit doesn't denormalise the client's name onto the relationship.
  Future<({String name, String photoUrl})> _clientDetails(String clientUid) async {
    const fallback = (name: 'Client', photoUrl: '');
    if (clientUid.isEmpty) return fallback;
    final cached = _clientDetailsCache[clientUid];
    if (cached != null) return cached;
    try {
      final data = (await _db.collection(FirestoreCollections.users).doc(clientUid).get()).data();
      final name = (data?['name'] as String?)?.trim();
      final details = (
        name: name == null || name.isEmpty ? fallback.name : name,
        photoUrl: data?['profileImageUrl'] as String? ?? data?['profilePicture'] as String? ?? '',
      );
      return _clientDetailsCache[clientUid] = details;
    } catch (e) {
      logDebug('FirestoreTrainingService: loading client $clientUid failed: $e');
      return fallback;
    }
  }

  Future<TrainingRelationship> sendRequest({
    required String coachId,
    required String clientUid,
    required String coachName,
    required String clientName,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final relationship = TrainingRelationshipModel(
      id: id,
      coachId: coachId,
      clientUid: clientUid,
      coachName: coachName,
      clientName: clientName,
      status: RelationshipStatus.pending,
      requestedAt: now,
    );
    final map = relationship.toMap();
    map['requestedAt'] = FieldValue.serverTimestamp();
    await _relationships.doc(id).set(map);
    return relationship;
  }

  /// Accepting also assigns the coach on clients/{clientUid}, in the same batch.
  Future<void> respondToRequest({
    required String relationshipId,
    required String clientUid,
    required String coachUid,
    required bool accept,
  }) async {
    final status = accept ? RelationshipStatus.active : RelationshipStatus.declined;
    final batch = _db.batch()
      ..update(_relationships.doc(relationshipId), {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    if (accept) {
      batch.update(
        _db.collection(FirestoreCollections.clients).doc(clientUid),
        {
          'currentCoachId': coachUid,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }
    await batch.commit();
  }

  Future<void> endRelationship(
      TrainingRelationship relationship, EndedBy endedBy) async {
    final batch = _db.batch();

    // 1. Mark relationship ended
    batch.update(
      _relationships.doc(relationship.id),
      {
        'status': RelationshipStatus.ended.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'endedAt': FieldValue.serverTimestamp(),
        'endedBy': endedBy.name,
      },
    );

    // 2. Clear currentCoachId on the client document
    batch.update(
      _db.collection(FirestoreCollections.clients).doc(relationship.clientUid),
      {
        'currentCoachId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }
}
