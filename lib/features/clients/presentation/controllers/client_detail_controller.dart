import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_party.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_type.dart';
import 'package:yeetcoach/features/calls/domain/repositories/i_call_repository.dart';
import 'package:yeetcoach/features/clients/domain/entities/client_profile.dart';
import 'package:yeetcoach/features/clients/domain/repositories/i_client_profile_repository.dart';
import 'package:yeetcoach/features/coach/domain/repositories/i_coach_repository.dart';
import 'package:yeetcoach/features/training/domain/entities/training_relationship.dart';
import 'package:yeetcoach/features/training/domain/repositories/i_training_repository.dart';
import '../../domain/entities/assigned_workout_plan.dart';
import '../../domain/entities/client_recovery.dart';
import '../../domain/entities/client_relationship_info.dart';
import '../../domain/entities/daily_goal_metric.dart';
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/entities/recovery_day.dart';
import '../../domain/entities/workout_log_summary.dart';
import '../../domain/repositories/i_client_insights_repository.dart';

/// Independently loaded parts of the screen, each with its own shimmer.
enum ClientDetailSection {
  recovery,
  relationship,
  notes,
  sleep,
  water,
  steps,
  workout,
  nutrition,
  plan,
}

enum RecoveryChartMode { week, month }

class ClientDetailController extends GetxController {
  final IClientProfileRepository _clientRepo;
  final ICallRepository _callRepo;
  final ICoachRepository _coachRepo;
  final IClientInsightsRepository _insightsRepo;
  final ITrainingRepository _trainingRepo;
  final FirebaseAuth _auth;

  ClientDetailController(
    this._clientRepo,
    this._callRepo,
    this._coachRepo,
    this._insightsRepo,
    this._trainingRepo, {
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final Rx<ClientProfile?> client = Rx<ClientProfile?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isStartingCall = false.obs;
  final RxBool isRemovingClient = false.obs;

  final RxSet<ClientDetailSection> loadingSections = ClientDetailSection.values.toSet().obs;

  final Rx<ClientRecovery> recovery = ClientRecovery.empty.obs;
  final Rx<RecoveryChartMode> chartMode = RecoveryChartMode.week.obs;
  final Rx<DateTime> chartAnchorDate = Rx<DateTime>(_dateOnly(DateTime.now()));
  final RxMap<String, RecoveryDay> recoveryRange = <String, RecoveryDay>{}.obs;
  final RxBool recoveryRangeLoading = true.obs;
  final RxnString recoveryRangeError = RxnString();
  StreamSubscription<Map<String, RecoveryDay>>? _recoveryRangeSub;

  final Rx<ClientRelationshipInfo?> relationship = Rx<ClientRelationshipInfo?>(null);
  final Rx<DailyGoalMetric?> sleep = Rx<DailyGoalMetric?>(null);
  final Rx<DailyGoalMetric?> water = Rx<DailyGoalMetric?>(null);
  final Rx<DailyGoalMetric?> steps = Rx<DailyGoalMetric?>(null);
  final Rx<WorkoutLogSummary?> workout = Rx<WorkoutLogSummary?>(null);

  /// The coach isn't allowed to read the client's workout log.
  final RxBool isWorkoutRestricted = false.obs;
  final Rx<NutritionSummary> nutrition = const NutritionSummary().obs;
  final Rx<int?> calorieTarget = Rx<int?>(null);
  final Rx<AssignedWorkoutPlan?> latestPlan = Rx<AssignedWorkoutPlan?>(null);
  final RxBool isPlanExpanded = false.obs;

  /// The coach's private note (coaches/{coachUid}/client_notes/{clientUid}).
  final RxString coachNotes = ''.obs;
  final RxBool isEditingNotes = false.obs;
  final RxBool isSavingNotes = false.obs;
  final TextEditingController notesController = TextEditingController();

  late final String clientUid;
  String _coachUid = '';
  StreamSubscription<ClientProfile?>? _sub;
  final List<StreamSubscription<Object?>> _insightSubs = [];

  @override
  void onInit() {
    super.onInit();
    // Pattern match so a missing or non-String uid falls back to '' instead of throwing.
    clientUid = switch (Get.arguments) {
      {'uid': String uid} => uid,
      _ => '',
    };
    if (clientUid.isEmpty) {
      isLoading.value = false;
      loadingSections.clear();
      logDebug('ClientDetailController: no uid in arguments');
      return;
    }
    _sub = _clientRepo.watchClient(clientUid).listen(
      (profile) {
        client.value = profile;
        isLoading.value = false;
      },
      onError: (Object e) {
        logDebug('watchClient error: $e');
        isLoading.value = false;
        showErrorSnackbar('Could not load client. Please try again.');
      },
    );
    _coachUid = _auth.currentUser?.uid ?? '';
    _watchInsights();
    _subscribeRecoveryRange();
  }

  bool isSectionLoading(ClientDetailSection section) => loadingSections.contains(section);

  void _watchInsights() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _watch(ClientDetailSection.recovery, _insightsRepo.watchRecovery(clientUid),
        (value) => recovery.value = value);
    _watch(ClientDetailSection.sleep,
        _insightsRepo.watchDailyMetric(clientUid, today, DailyMetric.sleep),
        (value) => sleep.value = value);
    _watch(ClientDetailSection.water,
        _insightsRepo.watchDailyMetric(clientUid, today, DailyMetric.water),
        (value) => water.value = value);
    _watch(ClientDetailSection.steps,
        _insightsRepo.watchDailyMetric(clientUid, today, DailyMetric.steps),
        (value) => steps.value = value);
    _watch(
      ClientDetailSection.workout,
      _insightsRepo.watchWorkoutLog(clientUid, today),
      (value) => workout.value = value,
      onError: (e) {
        if (e is RestrictedClientDataException) isWorkoutRestricted.value = true;
      },
    );
    _watch(ClientDetailSection.nutrition, _insightsRepo.watchNutrition(clientUid, today),
        (value) => nutrition.value = value);
    _watch(ClientDetailSection.plan, _insightsRepo.watchLatestWorkoutPlan(clientUid),
        (value) => latestPlan.value = value);

    if (_coachUid.isEmpty) {
      loadingSections
        ..remove(ClientDetailSection.relationship)
        ..remove(ClientDetailSection.notes);
    } else {
      _watch(
        ClientDetailSection.relationship,
        _insightsRepo.watchRelationship(clientUid: clientUid, coachUid: _coachUid),
        (info) => relationship.value = info,
      );
      _watch(
        ClientDetailSection.notes,
        _insightsRepo.watchCoachNotes(clientUid: clientUid, coachUid: _coachUid),
        (notes) {
          coachNotes.value = notes;
          if (!isEditingNotes.value) notesController.text = notes;
        },
      );
    }

    _loadCalorieTarget();
  }

  Future<void> _loadCalorieTarget() async {
    try {
      calorieTarget.value = await _insightsRepo.getDailyCalorieTarget(clientUid);
    } catch (e) {
      logDebug('getDailyCalorieTarget error: $e');
    }
  }

  /// A failed section stops shimmering and falls back to its empty state.
  void _watch<T>(
    ClientDetailSection section,
    Stream<T> stream,
    void Function(T value) onData, {
    void Function(Object error)? onError,
  }) {
    _insightSubs.add(stream.listen(
      (value) {
        onData(value);
        loadingSections.remove(section);
      },
      onError: (Object e) {
        logDebug('ClientDetailController: ${section.name} stream error: $e');
        onError?.call(e);
        loadingSections.remove(section);
      },
    ));
  }

  (DateTime start, DateTime end) get chartPeriod {
    final anchor = _dateOnly(chartAnchorDate.value);
    if (chartMode.value == RecoveryChartMode.week) {
      final monday = anchor.subtract(Duration(days: anchor.weekday - DateTime.monday));
      final sunday = monday.add(const Duration(days: 6));
      return (monday, sunday);
    }
    final start = DateTime(anchor.year, anchor.month, 1);
    final end = DateTime(anchor.year, anchor.month + 1, 0);
    return (start, end);
  }

  String get chartPeriodLabel {
    final (start, end) = chartPeriod;
    if (chartMode.value == RecoveryChartMode.week) {
      return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM').format(end)}';
    }
    return DateFormat('MMMM yyyy').format(start);
  }

  bool get canGoNext {
    final today = _dateOnly(DateTime.now());
    final (_, end) = chartPeriod;
    return end.isBefore(today);
  }

  void setChartMode(RecoveryChartMode mode) {
    if (chartMode.value == mode) return;
    chartMode.value = mode;
    _subscribeRecoveryRange();
  }

  void previousPeriod() {
    final anchor = _dateOnly(chartAnchorDate.value);
    chartAnchorDate.value = chartMode.value == RecoveryChartMode.week
        ? anchor.subtract(const Duration(days: 7))
        : DateTime(anchor.year, anchor.month - 1, 1);
    _subscribeRecoveryRange();
  }

  void nextPeriod() {
    if (!canGoNext) return;
    final anchor = _dateOnly(chartAnchorDate.value);
    chartAnchorDate.value = chartMode.value == RecoveryChartMode.week
        ? anchor.add(const Duration(days: 7))
        : DateTime(anchor.year, anchor.month + 1, 1);
    _subscribeRecoveryRange();
  }

  void _subscribeRecoveryRange() {
    _recoveryRangeSub?.cancel();
    recoveryRangeLoading.value = true;
    recoveryRangeError.value = null;
    final (start, end) = chartPeriod;
    _recoveryRangeSub = _insightsRepo.watchRecoveryRange(clientUid, start, end).listen(
      (days) {
        recoveryRange
          ..clear()
          ..addAll(days);
        recoveryRangeLoading.value = false;
      },
      onError: (Object e) {
        logDebug('ClientDetailController: recovery range error: $e');
        recoveryRange.clear();
        recoveryRangeError.value = 'Could not load recovery history.';
        recoveryRangeLoading.value = false;
      },
    );
  }

  static DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  String dateKey(DateTime day) => DateFormat('yyyy-MM-dd').format(_dateOnly(day));

  RecoveryDay? recoveryFor(DateTime day) => recoveryRange[dateKey(day)];

  void togglePlanExpanded() => isPlanExpanded.toggle();

  void startEditingNotes() {
    notesController.text = coachNotes.value;
    isEditingNotes.value = true;
  }

  void cancelEditingNotes() {
    notesController.text = coachNotes.value;
    isEditingNotes.value = false;
  }

  Future<void> updateTrainingDays(List<int> days) async {
    final profile = client.value;
    if (profile == null) return;
    final previous = profile.trainingDays;
    client.value = profile.copyWith(trainingDays: days);
    try {
      await _clientRepo.updateTrainingDays(profile.uid, days);
    } catch (e) {
      logDebug('ClientDetailController: saving training days failed: $e');
      final current = client.value;
      if (current != null) client.value = current.copyWith(trainingDays: previous);
      showErrorSnackbar('Could not save training days');
    }
  }

  Future<void> saveNotes() async {
    if (relationship.value == null || _coachUid.isEmpty || isSavingNotes.value) return;
    isSavingNotes.value = true;
    try {
      await _insightsRepo.saveCoachNotes(
        clientUid: clientUid,
        coachUid: _coachUid,
        notes: notesController.text.trim(),
      );
      isEditingNotes.value = false;
      showSuccessSnackbar('Note saved.');
    } catch (e) {
      logDebug('ClientDetailController: saving coach notes failed: $e');
      showErrorSnackbar('Could not save the note. Please try again.');
    } finally {
      isSavingNotes.value = false;
    }
  }

  /// Creates the ringing call document and opens the call screen; the
  /// onCallCreated Cloud Function pushes the incoming call to YeetFit.
  Future<void> startCall(CallType type) async {
    final profile = client.value;
    final coachUid = _auth.currentUser?.uid;
    if (profile == null || coachUid == null || isStartingCall.value) return;
    isStartingCall.value = true;
    try {
      final receiver = CallParty(
        uid: profile.uid,
        name: profile.name,
        photoUrl: profile.profileImageUrl ?? '',
      );
      final callId = await _callRepo.startCall(
        caller: await _callerParty(coachUid),
        receiver: receiver,
        type: type,
      );
      logDebug('ClientDetailController: started ${type.name} call $callId');
      Get.toNamed(AppRoutes.call, arguments: {'callId': callId, 'type': type, 'party': receiver});
    } catch (e) {
      logDebug('ClientDetailController: starting call failed: $e');
      showErrorSnackbar('Could not start the call. Please try again.');
    } finally {
      isStartingCall.value = false;
    }
  }

  /// Ends the training relationship (and clears clients/{uid}.currentCoachId in the same
  /// batch), then leaves the screen.
  Future<void> removeClient() async {
    if (isRemovingClient.value || clientUid.isEmpty || _coachUid.isEmpty) return;
    isRemovingClient.value = true;
    try {
      final relationshipId = relationship.value?.id ?? '${clientUid}_$_coachUid';
      final current = await _trainingRepo.getRelationship(relationshipId);
      if (current == null || current.status != RelationshipStatus.active) {
        logDebug('ClientDetailController: no active relationship $relationshipId');
        showErrorSnackbar('This client is no longer training with you.');
        return;
      }
      await _trainingRepo.endRelationship(current, EndedBy.coach);
      // Popped through the navigator first: Get.back would close an open snackbar instead.
      await Get.key.currentState?.maybePop();
      showSuccessSnackbar('Client removed');
    } catch (e) {
      logDebug('ClientDetailController: removing client failed: $e');
      showErrorSnackbar('Could not remove the client. Please try again.');
    } finally {
      isRemovingClient.value = false;
    }
  }

  void openChat() {
    final profile = client.value;
    if (profile == null) return;
    Get.toNamed(AppRoutes.chat, arguments: {
      'clientUid': profile.uid,
      'name': profile.name,
      'photoUrl': profile.profileImageUrl ?? '',
    });
  }

  /// The coach profile is preferred; the auth account is the fallback if it can't be read.
  Future<CallParty> _callerParty(String coachUid) async {
    try {
      final coach = await _coachRepo.getCoach(coachUid);
      if (coach != null) {
        return CallParty(uid: coachUid, name: coach.name, photoUrl: coach.profileImageUrl ?? '');
      }
    } catch (e) {
      logDebug('ClientDetailController: coach profile unavailable for call: $e');
    }
    final user = _auth.currentUser;
    return CallParty(
      uid: coachUid,
      name: user?.displayName ?? 'Your coach',
      photoUrl: user?.photoURL ?? '',
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    _recoveryRangeSub?.cancel();
    for (final sub in _insightSubs) {
      sub.cancel();
    }
    notesController.dispose();
    super.onClose();
  }
}
