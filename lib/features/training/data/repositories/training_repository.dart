import '../../domain/entities/training_relationship.dart';
import '../../domain/repositories/i_training_repository.dart';
import '../datasources/firestore_training_service.dart';

class TrainingRepository implements ITrainingRepository {
  final FirestoreTrainingService _service;
  TrainingRepository({FirestoreTrainingService? service})
      : _service = service ?? FirestoreTrainingService();

  @override
  Future<TrainingRelationship?> getRelationship(String id) =>
      _service.getRelationship(id);

  @override
  Stream<List<TrainingRelationship>> watchPendingRequests(
          String coachId) =>
      _service.watchPendingRequests(coachId);

  @override
  Stream<List<TrainingRelationship>> watchActiveRelationships(
          String coachId) =>
      _service.watchActiveRelationships(coachId);

  @override
  Stream<List<TrainingRelationship>> watchRecentDecisions(String coachId, {int limit = 10}) =>
      _service.watchRecentDecisions(coachId, limit: limit);

  @override
  Future<TrainingRelationship> sendRequest({
    required String coachId,
    required String clientUid,
    required String coachName,
    required String clientName,
  }) =>
      _service.sendRequest(
        coachId: coachId,
        clientUid: clientUid,
        coachName: coachName,
        clientName: clientName,
      );

  @override
  Future<void> respondToRequest({
    required String relationshipId,
    required String clientUid,
    required String coachUid,
    required bool accept,
  }) =>
      _service.respondToRequest(
        relationshipId: relationshipId,
        clientUid: clientUid,
        coachUid: coachUid,
        accept: accept,
      );

  @override
  Future<void> endRelationship(
          TrainingRelationship relationship, EndedBy endedBy) =>
      _service.endRelationship(relationship, endedBy);
}
