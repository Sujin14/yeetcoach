import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/clients/domain/entities/client_profile.dart';
import 'package:yeetcoach/features/clients/domain/repositories/i_client_profile_repository.dart';
import 'package:yeetcoach/features/coach/domain/entities/coach_profile.dart';
import 'package:yeetcoach/features/coach/domain/repositories/i_coach_repository.dart';
import 'package:yeetcoach/features/training/domain/entities/training_relationship.dart';
import 'package:yeetcoach/features/training/domain/repositories/i_training_repository.dart';
import '../../domain/entities/recovery_level.dart';
import '../../domain/repositories/i_dashboard_repository.dart';

class CoachDashboardController extends GetxController {
  final ITrainingRepository _trainingRepo;
  final IClientProfileRepository _clientRepo;
  final ICoachRepository _coachRepo;
  final IDashboardRepository _dashboardRepo;

  CoachDashboardController(
    this._trainingRepo,
    this._clientRepo,
    this._coachRepo,
    this._dashboardRepo,
  );

  final RxList<TrainingRelationship> pendingRequests = <TrainingRelationship>[].obs;
  final RxList<ClientProfile> activeClients = <ClientProfile>[].obs;
  final RxBool isLoadingRequests = true.obs;
  final RxBool isLoadingClients = true.obs;

  // Per-request loading state (for accept/reject buttons)
  final RxSet<String> processingIds = <String>{}.obs;

  final Rx<CoachProfile?> coach = Rx<CoachProfile?>(null);
  final RxBool isLoadingCoach = true.obs;

  /// Active training relationships, most recently updated first.
  final RxList<TrainingRelationship> activeRelationships = <TrainingRelationship>[].obs;
  final RxBool isLoadingRelationships = true.obs;

  /// Last 10 accepted or declined requests, for the Requests tab.
  final RxList<TrainingRelationship> recentDecisions = <TrainingRelationship>[].obs;
  final RxBool isLoadingRecent = true.obs;

  /// Clients whose trainingDays include today. Separate from [activeClients].
  final RxList<ClientProfile> todaysClients = <ClientProfile>[].obs;
  final RxBool isLoadingToday = true.obs;

  /// Keyed by client uid. A missing key means not loaded yet; a null value means no score shared.
  final RxMap<String, RecoveryLevel?> recoveryLevels = <String, RecoveryLevel?>{}.obs;

  StreamSubscription<List<TrainingRelationship>>? _requestsSub;
  StreamSubscription<List<ClientProfile>>? _clientsSub;
  StreamSubscription<List<ClientProfile>>? _todaysClientsSub;
  StreamSubscription<CoachProfile?>? _coachSub;
  StreamSubscription<List<TrainingRelationship>>? _relationshipsSub;
  StreamSubscription<List<TrainingRelationship>>? _recentSub;
  final List<StreamSubscription<RecoveryLevel?>> _recoverySubs = [];

  /// Sorted client uids the recovery streams were last opened for; null until the first run.
  String? _loadedClientsKey;

  @override
  void onInit() {
    super.onInit();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      logDebug('CoachDashboardController: no logged-in user, streams not started');
      isLoadingRequests.value = false;
      isLoadingClients.value = false;
      isLoadingCoach.value = false;
      isLoadingRelationships.value = false;
      isLoadingToday.value = false;
      isLoadingRecent.value = false;
      return;
    }
    _subscribeRequests(uid);
    _subscribeClients(uid);
    _subscribeTodaysClients(uid);
    _subscribeCoach(uid);
    _subscribeRelationships(uid);
    _subscribeRecentDecisions(uid);
  }

  void _subscribeRecentDecisions(String coachId) {
    _recentSub = _trainingRepo.watchRecentDecisions(coachId).listen(
      (list) {
        recentDecisions.assignAll(list);
        isLoadingRecent.value = false;
      },
      onError: (Object e) {
        logDebug('watchRecentDecisions error: $e');
        isLoadingRecent.value = false;
      },
    );
  }

  void _subscribeCoach(String coachId) {
    _coachSub = _coachRepo.watchCoach(coachId).listen(
      (profile) {
        coach.value = profile;
        isLoadingCoach.value = false;
      },
      onError: (Object e) {
        logDebug('watchCoach error: $e');
        isLoadingCoach.value = false;
      },
    );
  }

  void _subscribeRelationships(String coachId) {
    _relationshipsSub = _trainingRepo.watchActiveRelationships(coachId).listen(
      (list) {
        activeRelationships.assignAll(
          [...list]..sort((a, b) => lastActivityOf(b).compareTo(lastActivityOf(a))),
        );
        isLoadingRelationships.value = false;
        _watchRecoveryLevels();
      },
      onError: (Object e) {
        logDebug('watchActiveRelationships error: $e');
        isLoadingRelationships.value = false;
      },
    );
  }

  /// The relationship's last change, shown as the client's last activity.
  static DateTime lastActivityOf(TrainingRelationship relationship) =>
      relationship.updatedAt ?? relationship.acceptedAt ?? relationship.requestedAt;

  /// Opens one clients/{uid} snapshot stream per active client, and only when that set changes.
  void _watchRecoveryLevels() {
    final uids = activeRelationships
        .map((relationship) => relationship.clientUid)
        .where((uid) => uid.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final key = uids.join(',');
    if (key == _loadedClientsKey) return;
    _loadedClientsKey = key;

    for (final subscription in _recoverySubs) {
      subscription.cancel();
    }
    _recoverySubs.clear();
    recoveryLevels.removeWhere((uid, _) => !uids.contains(uid));

    for (final uid in uids) {
      _recoverySubs.add(
        _dashboardRepo.watchRecoveryLevel(uid).listen(
          (level) => recoveryLevels[uid] = level,
          onError: (Object e) {
            logDebug('CoachDashboardController: recovery stream for $uid failed: $e');
            recoveryLevels[uid] = null;
          },
        ),
      );
    }
  }

  /// Pull-to-refresh. Dashboard data is already live, including recovery snapshots.
  Future<void> refreshDashboard() async {}

  void _subscribeRequests(String coachId) {
    _requestsSub = _trainingRepo.watchPendingRequests(coachId).listen(
      (list) {
        pendingRequests.assignAll(list);
        isLoadingRequests.value = false;
      },
      onError: (Object e) {
        logDebug('watchPendingRequests error: $e');
        isLoadingRequests.value = false;
      },
    );
  }

  void _subscribeTodaysClients(String coachId) {
    _todaysClientsSub = _clientRepo.watchTodaysClients(coachId).listen(
      (list) {
        todaysClients.assignAll(list);
        isLoadingToday.value = false;
      },
      onError: (Object e) {
        logDebug('watchTodaysClients error: $e');
        isLoadingToday.value = false;
      },
    );
  }

  void _subscribeClients(String coachId) {
    _clientsSub = _clientRepo.watchCoachClients(coachId).listen(
      (list) {
        activeClients.assignAll(list);
        isLoadingClients.value = false;
      },
      onError: (Object e) {
        logDebug('watchCoachClients error: $e');
        isLoadingClients.value = false;
      },
    );
  }

  /// The card leaves the list through the pending-requests stream once the status changes.
  Future<void> respondToRequest(String id, String clientUid, {required bool accept}) async {
    final coachUid = FirebaseAuth.instance.currentUser?.uid;
    if (coachUid == null || processingIds.contains(id)) return;
    final clientName =
        pendingRequests.firstWhereOrNull((request) => request.id == id)?.clientName ?? 'The client';
    processingIds.add(id);
    try {
      await _trainingRepo.respondToRequest(
        relationshipId: id,
        clientUid: clientUid,
        coachUid: coachUid,
        accept: accept,
      );
      showSuccessSnackbar(
        accept ? '$clientName is now your client.' : '$clientName\'s request was declined.',
      );
    } catch (e) {
      logDebug('respondToRequest(accept: $accept) error: $e');
      showErrorSnackbar(
        accept
            ? 'Could not accept request. Please try again.'
            : 'Could not decline request. Please try again.',
      );
    } finally {
      processingIds.remove(id);
    }
  }

  @override
  void onClose() {
    _requestsSub?.cancel();
    _clientsSub?.cancel();
    _todaysClientsSub?.cancel();
    _coachSub?.cancel();
    _relationshipsSub?.cancel();
    _recentSub?.cancel();
    for (final subscription in _recoverySubs) {
      subscription.cancel();
    }
    super.onClose();
  }
}
