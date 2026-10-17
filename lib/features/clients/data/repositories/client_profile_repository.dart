import '../../domain/entities/client_profile.dart';
import '../../domain/repositories/i_client_profile_repository.dart';
import '../datasources/firestore_client_profile_service.dart';

class ClientProfileRepository implements IClientProfileRepository {
  final FirestoreClientProfileService _service;
  ClientProfileRepository({FirestoreClientProfileService? service})
      : _service = service ?? FirestoreClientProfileService();

  @override
  Future<ClientProfile?> getClient(String uid) =>
      _service.getClient(uid);

  @override
  Stream<ClientProfile?> watchClient(String uid) =>
      _service.watchClient(uid);

  @override
  Stream<List<ClientProfile>> watchCoachClients(String coachId) =>
      _service.watchCoachClients(coachId);

  @override
  Stream<List<ClientProfile>> watchTodaysClients(String coachUid) =>
      _service.watchTodaysClients(coachUid);

  @override
  Future<void> createClient(ClientProfile profile) =>
      _service.createClient(profile);

  @override
  Future<void> updateClient(ClientProfile profile) =>
      _service.updateClient(profile);

  @override
  Future<void> updateTrainingDays(String clientUid, List<int> days) =>
      _service.updateTrainingDays(clientUid, days);

  @Deprecated(
    'Use TrainingRepository.endRelationship — it clears currentCoachId '
    'atomically. Only call this directly for admin/account-deletion flows.',
  )
  @override
  Future<void> clearCoachId(String clientUid) =>
      _service.clearCoachId(clientUid);
}
