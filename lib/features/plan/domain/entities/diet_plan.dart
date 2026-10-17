import 'package:flutter/foundation.dart';

@immutable
class DietPlan {
  final String id;
  final String clientUid;
  final String trainerId;
  final String title;
  final String description;
  final List<MealEntry> meals;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DietPlan({
    required this.id,
    required this.clientUid,
    required this.trainerId,
    required this.title,
    required this.description,
    required this.meals,
    required this.createdAt,
    required this.updatedAt,
  });

  DietPlan copyWith({
    String? id,
    String? clientUid,
    String? trainerId,
    String? title,
    String? description,
    List<MealEntry>? meals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DietPlan(
      id: id ?? this.id,
      clientUid: clientUid ?? this.clientUid,
      trainerId: trainerId ?? this.trainerId,
      title: title ?? this.title,
      description: description ?? this.description,
      meals: meals ?? this.meals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DietPlan &&
          other.id == id &&
          other.clientUid == clientUid &&
          other.trainerId == trainerId &&
          other.title == title &&
          other.description == description &&
          listEquals(other.meals, meals) &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        clientUid,
        trainerId,
        title,
        description,
        Object.hashAll(meals),
        createdAt,
        updatedAt,
      );
}

@immutable
class MealEntry {
  final String mealName;
  final String time;
  final List<FoodItem> foods;

  const MealEntry({required this.mealName, required this.time, required this.foods});

  MealEntry copyWith({String? mealName, String? time, List<FoodItem>? foods}) {
    return MealEntry(
      mealName: mealName ?? this.mealName,
      time: time ?? this.time,
      foods: foods ?? this.foods,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealEntry &&
          other.mealName == mealName &&
          other.time == time &&
          listEquals(other.foods, foods);

  @override
  int get hashCode => Object.hash(mealName, time, Object.hashAll(foods));
}

@immutable
class FoodItem {
  final String name;
  final String unit;
  final String notes;
  final double quantity;
  final double protein;
  final double carbs;
  final double fats;
  final int calories;
  const FoodItem({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.notes = '',
  });
  FoodItem copyWith({
    String? name,
    String? unit,
    String? notes,
    double? quantity,
    double? protein,
    double? carbs,
    double? fats,
    int? calories,
  }) {
    return FoodItem(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      calories: calories ?? this.calories,
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItem &&
          other.name == name &&
          other.unit == unit &&
          other.notes == notes &&
          other.quantity == quantity &&
          other.protein == protein &&
          other.carbs == carbs &&
          other.fats == fats &&
          other.calories == calories;
  @override
  int get hashCode =>
      Object.hash(name, unit, notes, quantity, protein, carbs, fats, calories);
}
