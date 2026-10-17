import 'dart:async';
import 'package:get/get.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/repositories/i_challenge_repository.dart';

/// Route arguments: {'id': String, 'challenge': Challenge?}. The optional
/// challenge renders immediately while the live copy loads.
class ChallengeDetailController extends GetxController {
  final IChallengeRepository _repo;

  ChallengeDetailController(this._repo);

  final Rx<Challenge?> challenge = Rx<Challenge?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isEnding = false.obs;

  /// In assignment order; empty until loaded.
  final RxList<ChallengeMember> members = <ChallengeMember>[].obs;
  final RxBool isLoadingMembers = true.obs;
  final Rx<DateTime> now = DateTime.now().obs;

  StreamSubscription<Challenge?>? _challengeSub;
  Timer? _clock;
  String _loadedMembersKey = '';

  @override
  void onInit() {
    super.onInit();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => now.value = DateTime.now());
    final args = Get.arguments;
    final id = args is Map ? args['id'] as String? : null;
    final initial = args is Map ? args['challenge'] : null;
    if (initial is Challenge) {
      challenge.value = initial;
      isLoading.value = false;
      _loadMembers(initial.assignedTo);
    }
    if (id == null || id.isEmpty) {
      logDebug('ChallengeDetailController: missing challenge id');
      isLoading.value = false;
      isLoadingMembers.value = false;
      return;
    }
    _challengeSub = _repo.watchChallenge(id).listen(
      (value) {
        challenge.value = value;
        isLoading.value = false;
        if (value == null) {
          isLoadingMembers.value = false;
        } else {
          _loadMembers(value.assignedTo);
        }
      },
      onError: (Object e) {
        logDebug('ChallengeDetailController: watchChallenge error: $e');
        isLoading.value = false;
        isLoadingMembers.value = false;
      },
    );
  }

  Future<void> _loadMembers(List<String> uids) async {
    final key = uids.join(',');
    if (key == _loadedMembersKey) return;
    _loadedMembersKey = key;
    if (uids.isEmpty) {
      members.clear();
      isLoadingMembers.value = false;
      return;
    }
    isLoadingMembers.value = true;
    final byUid = await _repo.getMembers(uids);
    if (key != _loadedMembersKey) return;
    members.assignAll(uids.map((uid) => byUid[uid]).whereType<ChallengeMember>());
    isLoadingMembers.value = false;
  }

  Future<void> endChallenge() async {
    final current = challenge.value;
    if (current == null || isEnding.value) return;
    isEnding.value = true;
    try {
      await _repo.endChallenge(current);
      showSuccessSnackbar('"${current.title}" has ended.');
    } catch (e) {
      logDebug('ChallengeDetailController: endChallenge failed: $e');
      showErrorSnackbar('Could not end the challenge. Please try again.');
    } finally {
      isEnding.value = false;
    }
  }

  @override
  void onClose() {
    _challengeSub?.cancel();
    _clock?.cancel();
    super.onClose();
  }
}
