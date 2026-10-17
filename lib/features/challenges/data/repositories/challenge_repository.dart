import '../../domain/entities/challenge.dart';
import '../../domain/repositories/i_challenge_repository.dart';
import '../datasources/firestore_challenge_service.dart';

class ChallengeRepository implements IChallengeRepository {
  final FirestoreChallengeService _service;

  ChallengeRepository({FirestoreChallengeService? service})
      : _service = service ?? FirestoreChallengeService();

  @override
  Stream<List<Challenge>> watchCoachChallenges(String coachId) =>
      _service.watchCoachChallenges(coachId);

  @override
  Stream<Challenge?> watchChallenge(String challengeId) => _service.watchChallenge(challengeId);

  @override
  Future<void> createChallenge({required String coachId, required NewChallenge challenge}) =>
      _service.createChallenge(coachId: coachId, challenge: challenge);

  @override
  Future<void> endChallenge(Challenge challenge) => _service.endChallenge(challenge);

  @override
  Future<Map<String, ChallengeMember>> getMembers(Iterable<String> uids) =>
      _service.getMembers(uids);
}
