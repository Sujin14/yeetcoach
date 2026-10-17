import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/plan/domain/entities/workout_plan.dart';
import 'package:yeetcoach/features/plan/domain/repositories/plan_repository.dart';

class WorkoutPlanController extends GetxController {
  WorkoutPlanController(this._repository, {FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final PlanRepository _repository;
  final FirebaseAuth _auth;
  static const _uuid = Uuid();

  // ── identity ──────────────────────────────────────────────────────────────
  String clientUid = '';
  String coachUid = '';
  String? planId; // null = create, non-null = edit
  DateTime? _createdAt;

  // ── form state ────────────────────────────────────────────────────────────
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxList<WorkoutDay> days = <WorkoutDay>[].obs;
  final RxBool isSaving = false.obs;

  // ── lifecycle ─────────────────────────────────────────────────────────────

  /// Expects `{'uid': String}` and optionally `{'plan': WorkoutPlan}` to edit an existing plan.
  void setupWithArguments(Map args) {
    clientUid = switch (args) {
      {'uid': String uid} => uid,
      _ => '',
    };
    coachUid = _auth.currentUser?.uid ?? '';
    if (args case {'plan': WorkoutPlan existing}) {
      planId = existing.id;
      _createdAt = existing.createdAt;
      title.value = existing.title;
      description.value = existing.description;
      days.assignAll(existing.days);
    }
  }

  // ── days ──────────────────────────────────────────────────────────────────
  void addDay([String? label]) {
    final trimmed = label?.trim() ?? '';
    days.add(WorkoutDay(
      dayLabel: trimmed.isEmpty ? 'Day ${days.length + 1}' : trimmed,
      exercises: const [],
    ));
  }

  void removeDay(int index) {
    if (!_isValidDayIndex(index)) return;
    days.removeAt(index);
  }

  void updateDayLabel(int index, String label) {
    if (!_isValidDayIndex(index)) return;
    days[index] = days[index].copyWith(dayLabel: label);
  }

  /// Uses ReorderableListView.onReorderItem semantics: [newIndex] is already adjusted for removal.
  void reorderDays(int oldIndex, int newIndex) {
    if (!_isValidDayIndex(oldIndex) || oldIndex == newIndex) return;
    final day = days.removeAt(oldIndex);
    days.insert(newIndex.clamp(0, days.length), day);
  }

  // ── exercises ─────────────────────────────────────────────────────────────
  void addExercise(int dayIndex, ExerciseEntry entry) {
    if (!_isValidDayIndex(dayIndex)) return;
    final day = days[dayIndex];
    days[dayIndex] = day.copyWith(exercises: [...day.exercises, entry]);
  }

  void updateExercise(int dayIndex, int exIndex, ExerciseEntry entry) {
    if (!_isValidExerciseIndex(dayIndex, exIndex)) return;
    final day = days[dayIndex];
    days[dayIndex] = day.copyWith(exercises: [...day.exercises]..[exIndex] = entry);
  }

  void removeExercise(int dayIndex, int exIndex) {
    if (!_isValidExerciseIndex(dayIndex, exIndex)) return;
    final day = days[dayIndex];
    days[dayIndex] = day.copyWith(exercises: [...day.exercises]..removeAt(exIndex));
  }

  // ── save ──────────────────────────────────────────────────────────────────
  Future<bool> savePlan() async {
    final validationError = _validate();
    if (validationError != null) {
      showErrorSnackbar(validationError);
      return false;
    }

    final isCreate = planId == null;
    final now = DateTime.now();
    final plan = WorkoutPlan(
      id: planId ?? _uuid.v4(),
      clientUid: clientUid,
      trainerId: coachUid,
      title: title.value.trim(),
      description: description.value.trim(),
      days: List.unmodifiable(days),
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    isSaving.value = true;
    try {
      final saved = await _repository.saveWorkoutPlan(plan);
      if (!saved) {
        showErrorSnackbar('Could not save plan. Please try again.');
        return false;
      }
      planId = plan.id;
      _createdAt = plan.createdAt;
      logDebug('WorkoutPlanController: saved plan ${plan.id} (create: $isCreate)');
      showSuccessSnackbar(isCreate ? 'Plan created.' : 'Changes saved.');
      return true;
    } finally {
      isSaving.value = false;
    }
  }

  String? _validate() {
    if (clientUid.isEmpty) return 'No client selected. Please go back and try again.';
    if (coachUid.isEmpty) return 'You must be logged in to save a plan.';
    if (title.value.trim().isEmpty) return 'Please give this plan a name.';
    if (days.isEmpty) return 'Add at least one training day.';
    final emptyDay = days.firstWhereOrNull((day) => day.exercises.isEmpty);
    if (emptyDay != null) return '"${emptyDay.dayLabel}" has no exercises.';
    return null;
  }

  bool _isValidDayIndex(int index) => index >= 0 && index < days.length;

  bool _isValidExerciseIndex(int dayIndex, int exIndex) =>
      _isValidDayIndex(dayIndex) && exIndex >= 0 && exIndex < days[dayIndex].exercises.length;
}
