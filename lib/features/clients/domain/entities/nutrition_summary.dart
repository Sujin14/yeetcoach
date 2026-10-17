import 'package:flutter/foundation.dart';

/// Totals of the food entries a client logged for one day.
@immutable
class NutritionSummary {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int entryCount;

  const NutritionSummary({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.entryCount = 0,
  });

  bool get hasEntries => entryCount > 0;

  NutritionSummary copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    int? entryCount,
  }) {
    return NutritionSummary(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      entryCount: entryCount ?? this.entryCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionSummary &&
          other.calories == calories &&
          other.protein == protein &&
          other.carbs == carbs &&
          other.fat == fat &&
          other.entryCount == entryCount;

  @override
  int get hashCode => Object.hash(calories, protein, carbs, fat, entryCount);
}
