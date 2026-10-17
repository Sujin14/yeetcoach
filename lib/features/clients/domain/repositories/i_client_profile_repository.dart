import '../entities/client_profile.dart';

abstract class IClientProfileRepository {
  Future<ClientProfile?> getClient(String uid);
  Stream<ClientProfile?> watchClient(String uid);

  /// Stream of all clients whose currentCoachId == coachId.
  Stream<List<ClientProfile>> watchCoachClients(String coachId);

  /// Clients of this coach whose trainingDays include today's weekday (1 = Monday … 7 = Sunday).
  Stream<List<ClientProfile>> watchTodaysClients(String coachUid);

  Future<void> createClient(ClientProfile profile);
  Future<void> updateClient(ClientProfile profile);

  /// Writes clients/{clientUid}.trainingDays. Weekday ints: 1 = Monday … 7 = Sunday.
  Future<void> updateTrainingDays(String clientUid, List<int> days);

  /// Prefer [ITrainingRepository.endRelationship], which clears this field
  /// atomically in the same batch that updates the relationship status.
  /// Use this method only for administrative cleanup (e.g. account deletion).
  @Deprecated(
    'Use TrainingRepository.endRelationship — it clears currentCoachId '
    'atomically. Only call this directly for admin/account-deletion flows.',
  )
  Future<void> clearCoachId(String clientUid);
}
