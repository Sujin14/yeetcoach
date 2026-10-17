import '../entities/challenge.dart';

abstract class IChallengeRepository {
  /// Every challenge created by [coachId], newest first.
  Stream<List<Challenge>> watchCoachChallenges(String coachId);

  /// Emits null if the challenge is deleted.
  Stream<Challenge?> watchChallenge(String challengeId);

  Future<void> createChallenge({required String coachId, required NewChallenge challenge});

  /// Sets status 'ended' and, if it hasn't ended yet, pulls endDate to now so YeetFit stops listing it.
  Future<void> endChallenge(Challenge challenge);

  /// Unknown or unreadable users come back with a placeholder name.
  Future<Map<String, ChallengeMember>> getMembers(Iterable<String> uids);
}
