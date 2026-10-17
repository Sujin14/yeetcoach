import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/repositories/i_challenge_repository.dart';

/// Backs the Challenges tab. One stream of the coach's challenges feeds all three lists.
class ChallengesController extends GetxController {
  final IChallengeRepository _repo;

  ChallengesController(this._repo);

  /// Newest first, as streamed.
  final RxList<Challenge> challenges = <Challenge>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isCreating = false.obs;
  final RxSet<String> endingIds = <String>{}.obs;

  /// Assigned clients by uid, shared by every card.
  final RxMap<String, ChallengeMember> members = <String, ChallengeMember>{}.obs;

  /// Ticks every minute so "days left" labels and the active/ended split stay current.
  final Rx<DateTime> now = DateTime.now().obs;

  StreamSubscription<List<Challenge>>? _challengesSub;
  Timer? _clock;
  final Set<String> _requestedMemberIds = {};
  String _coachUid = '';

  List<Challenge> get activeChallenges =>
      challenges.where((challenge) => !challenge.isEndedAt(now.value)).toList()
        ..sort((a, b) => a.endDate.compareTo(b.endDate));

  List<Challenge> get endedChallenges =>
      challenges.where((challenge) => challenge.isEndedAt(now.value)).toList()
        ..sort((a, b) => b.endDate.compareTo(a.endDate));

  @override
  void onInit() {
    super.onInit();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => now.value = DateTime.now());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    _coachUid = uid;
    _challengesSub = _repo.watchCoachChallenges(uid).listen(
      (list) {
        challenges.assignAll(list);
        isLoading.value = false;
        hasError.value = false;
        _loadMembers(list.expand((challenge) => challenge.assignedTo));
      },
      onError: (Object e) {
        logDebug('ChallengesController: watchCoachChallenges error: $e');
        isLoading.value = false;
        hasError.value = true;
      },
    );
  }

  Future<void> _loadMembers(Iterable<String> uids) async {
    final missing = uids.where(_requestedMemberIds.add).toList();
    if (missing.isEmpty) return;
    members.addAll(await _repo.getMembers(missing));
  }

  /// Returns true when saved, so the sheet can close.
  Future<bool> createChallenge(NewChallenge challenge) async {
    if (_coachUid.isEmpty || isCreating.value) return false;
    isCreating.value = true;
    try {
      await _repo.createChallenge(coachId: _coachUid, challenge: challenge);
      showSuccessSnackbar('Challenge created! 🏆');
      return true;
    } catch (e) {
      logDebug('ChallengesController: createChallenge failed: $e');
      showErrorSnackbar('Could not create the challenge. Please try again.');
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> endChallenge(Challenge challenge) async {
    if (!endingIds.add(challenge.id)) return;
    try {
      await _repo.endChallenge(challenge);
      showSuccessSnackbar('"${challenge.title}" has ended.');
    } catch (e) {
      logDebug('ChallengesController: endChallenge failed: $e');
      showErrorSnackbar('Could not end the challenge. Please try again.');
    } finally {
      endingIds.remove(challenge.id);
    }
  }

  @override
  void onClose() {
    _challengesSub?.cancel();
    _clock?.cancel();
    super.onClose();
  }
}
