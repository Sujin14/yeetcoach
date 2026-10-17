import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/plan/domain/entities/diet_plan.dart';
import 'package:yeetcoach/features/plan/domain/repositories/plan_repository.dart';

class DietPlanController extends GetxController {
  DietPlanController(this._repository, {FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

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
  final RxList<MealEntry> meals = <MealEntry>[].obs;
  final RxBool isSaving = false.obs;

  // ── lifecycle ─────────────────────────────────────────────────────────────

  /// Expects `{'uid': String}` and optionally `{'plan': DietPlan}` to edit an existing plan.
  void setupWithArguments(Map args) {
    clientUid = switch (args) {
      {'uid': String uid} => uid,
      _ => '',
    };
    coachUid = _auth.currentUser?.uid ?? '';
    if (args case {'plan': DietPlan existing}) {
      planId = existing.id;
      _createdAt = existing.createdAt;
      title.value = existing.title;
      description.value = existing.description;
      meals.assignAll(existing.meals);
    }
  }

  // ── meals ─────────────────────────────────────────────────────────────────

  /// [mealName] defaults to "Meal N" when blank.
  void addMeal(String? mealName, {String time = ''}) {
    final trimmed = mealName?.trim() ?? '';
    meals.add(MealEntry(
      mealName: trimmed.isEmpty ? 'Meal ${meals.length + 1}' : trimmed,
      time: time.trim(),
      foods: const [],
    ));
  }

  void removeMeal(int index) {
    if (!_isValidMealIndex(index)) return;
    meals.removeAt(index);
  }

  void updateMeal(int index, {String? mealName, String? time}) {
    if (!_isValidMealIndex(index)) return;
    meals[index] = meals[index].copyWith(mealName: mealName, time: time);
  }

  // ── foods ─────────────────────────────────────────────────────────────────
  void addFood(int mealIndex, FoodItem food) {
    if (!_isValidMealIndex(mealIndex)) return;
    final meal = meals[mealIndex];
    meals[mealIndex] = meal.copyWith(foods: [...meal.foods, food]);
  }

  void removeFood(int mealIndex, int foodIndex) {
    if (!_isValidMealIndex(mealIndex)) return;
    final meal = meals[mealIndex];
    if (foodIndex < 0 || foodIndex >= meal.foods.length) return;
    meals[mealIndex] = meal.copyWith(foods: [...meal.foods]..removeAt(foodIndex));
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
    final plan = DietPlan(
      id: planId ?? _uuid.v4(),
      clientUid: clientUid,
      trainerId: coachUid,
      title: title.value.trim(),
      description: description.value.trim(),
      meals: List.unmodifiable(meals),
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    isSaving.value = true;
    try {
      final saved = await _repository.saveDietPlan(plan);
      if (!saved) {
        showErrorSnackbar('Could not save plan. Please try again.');
        return false;
      }
      planId = plan.id;
      _createdAt = plan.createdAt;
      logDebug('DietPlanController: saved plan ${plan.id} (create: $isCreate)');
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
    if (meals.isEmpty) return 'Add at least one meal.';
    final emptyMeal = meals.firstWhereOrNull((meal) => meal.foods.isEmpty);
    if (emptyMeal != null) return '"${emptyMeal.mealName}" has no food items.';
    return null;
  }

  bool _isValidMealIndex(int index) => index >= 0 && index < meals.length;
}
