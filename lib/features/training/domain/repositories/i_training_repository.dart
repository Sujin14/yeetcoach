import '../entities/training_relationship.dart';

abstract class ITrainingRepository {
  Future<TrainingRelationship?> getRelationship(String id);

  /// Pending requests aimed at this coach.
  Stream<List<TrainingRelationship>> watchPendingRequests(String coachId);

  /// Active relationships for this coach (used for client list).
  Stream<List<TrainingRelationship>> watchActiveRelationships(
      String coachId);

  /// The last [limit] requests this coach accepted or declined, newest decision first.
  Stream<List<TrainingRelationship>> watchRecentDecisions(String coachId, {int limit = 10});

  /// Creates the relationship document; status must be 'pending'.
  Future<TrainingRelationship> sendRequest({
    required String coachId,
    required String clientUid,
    required String coachName,
    required String clientName,
  });

  /// Accepting atomically marks the relationship active and sets the client's
  /// currentCoachId; declining only marks the relationship declined.
  Future<void> respondToRequest({
    required String relationshipId,
    required String clientUid,
    required String coachUid,
    required bool accept,
  });

  /// Atomically marks the relationship ended, records who ended it,
  /// and clears the client's currentCoachId.
  Future<void> endRelationship(TrainingRelationship relationship, EndedBy endedBy);
}
