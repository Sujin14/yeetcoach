import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/diet_plan.dart';
import 'firestore_parsing.dart';

class DietPlanModel extends DietPlan {
  static const planType = 'diet';

  const DietPlanModel({
    required super.id,
    required super.clientUid,
    required super.trainerId,
    required super.title,
    required super.description,
    required super.meals,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DietPlanModel.fromEntity(DietPlan plan) {
    return DietPlanModel(
      id: plan.id,
      clientUid: plan.clientUid,
      trainerId: plan.trainerId,
      title: plan.title,
      description: plan.description,
      meals: plan.meals,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
    );
  }

  /// [id] is the Firestore document id; falls back to an `id` field in [map].
  factory DietPlanModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return DietPlanModel(
      id: id ?? FirestoreParsing.toStringValue(map['id']),
      clientUid: FirestoreParsing.toStringValue(map['clientUid']),
      trainerId: FirestoreParsing.toStringValue(map['trainerId']),
      title: FirestoreParsing.toStringValue(map['title']),
      description: FirestoreParsing.toStringValue(map['description']),
      meals: FirestoreParsing.toMapList(map['meals']).map(MealEntryModel.fromMap).toList(),
      createdAt: FirestoreParsing.toDateTime(map['createdAt']),
      updatedAt: FirestoreParsing.toDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trainerId': trainerId,
      'clientUid': clientUid,
      'type': planType,
      'title': title,
      'description': description,
      'meals': meals.map((meal) => MealEntryModel.fromEntity(meal).toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Full document read by YeetFit's PlanModel at users/{clientUid}/diets/{id}, used on create.
  Map<String, dynamic> toClientPlanMap() => {
        ..._clientPlanFields(),
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

  /// Leaves out isFavorite (owned by the client) and createdAt, so edits preserve them.
  Map<String, dynamic> toClientPlanUpdateMap() => {
        ..._clientPlanFields(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> _clientPlanFields() {
    final foods = meals.expand((meal) => meal.foods).toList();
    final int totalCalories = foods.fold(0, (total, food) => total + food.calories);
    final double totalProtein = foods.fold(0.0, (total, food) => total + food.protein);
    final double totalCarbs = foods.fold(0.0, (total, food) => total + food.carbs);
    final double totalFats = foods.fold(0.0, (total, food) => total + food.fats);
    return {
      'title': title,
      'type': planType,
      'userId': clientUid,
      'assignedBy': trainerId,
      'totalCalories': totalCalories,
      'totalMacronutrients': clientMacros(totalProtein, totalCarbs, totalFats),
      'details': <String, dynamic>{
        'description': description,
        'category': 'nutrition',
        'meals': _clientMealsByName(),
      },
    };
  }

  /// YeetFit keys meals by name, so blank or duplicate names get unique keys instead of overwriting.
  Map<String, dynamic> _clientMealsByName() {
    final mealsByName = <String, dynamic>{};
    for (final (index, meal) in meals.indexed) {
      final trimmed = meal.mealName.trim();
      final baseName = trimmed.isEmpty ? 'Meal ${index + 1}' : trimmed;
      var name = baseName;
      for (var suffix = 2; mealsByName.containsKey(name); suffix++) {
        name = '$baseName ($suffix)';
      }
      mealsByName[name] = MealEntryModel.fromEntity(meal).toClientPlanMap();
    }
    return mealsByName;
  }

  /// The form collects protein only, so carbs and fats are always 0.
  static Map<String, double> clientMacros(double protein, double carbs, double fats) =>
      <String, double>{'protein': protein, 'carbs': carbs, 'fats': fats};
}

class MealEntryModel extends MealEntry {
  const MealEntryModel({required super.mealName, required super.time, required super.foods});

  factory MealEntryModel.fromEntity(MealEntry meal) {
    return MealEntryModel(mealName: meal.mealName, time: meal.time, foods: meal.foods);
  }

  factory MealEntryModel.fromMap(Map<String, dynamic> map) {
    return MealEntryModel(
      mealName: FirestoreParsing.toStringValue(map['mealName']),
      time: FirestoreParsing.toStringValue(map['time']),
      foods: FirestoreParsing.toMapList(map['foods']).map(FoodItemModel.fromMap).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealName': mealName,
      'time': time,
      'foods': foods.map((food) => FoodItemModel.fromEntity(food).toMap()).toList(),
    };
  }

  Map<String, dynamic> toClientPlanMap() {
    final int calories = foods.fold(0, (total, food) => total + food.calories);
    final double protein = foods.fold(0.0, (total, food) => total + food.protein);
    final double carbs = foods.fold(0.0, (total, food) => total + food.carbs);
    final double fats = foods.fold(0.0, (total, food) => total + food.fats);
    return {
      'time': time,
      'calories': calories,
      'macronutrients': DietPlanModel.clientMacros(protein, carbs, fats),
      'foods': foods.map((food) => FoodItemModel.fromEntity(food).toClientPlanMap()).toList(),
    };
  }
}

class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.name,
    required super.unit,
    required super.quantity,
    required super.calories,
    super.protein = 0,
    super.carbs = 0,
    super.fats = 0,
    super.notes,
  });

  factory FoodItemModel.fromEntity(FoodItem food) {
    return FoodItemModel(
      name: food.name,
      unit: food.unit,
      quantity: food.quantity,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fats: food.fats,
      notes: food.notes,
    );
  }

  factory FoodItemModel.fromMap(Map<String, dynamic> map) {
    return FoodItemModel(
      name: FirestoreParsing.toStringValue(map['name']),
      unit: FirestoreParsing.toStringValue(map['unit']),
      quantity: FirestoreParsing.toDouble(map['quantity']),
      calories: FirestoreParsing.toInt(map['calories']),
      protein: FirestoreParsing.toDouble(map['protein']),
      carbs: FirestoreParsing.toDouble(map['carbs']),
      fats: FirestoreParsing.toDouble(map['fats']),
      notes: FirestoreParsing.toStringValue(map['notes']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'notes': notes,
    };
  }

  Map<String, dynamic> toClientPlanMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'macronutrients': DietPlanModel.clientMacros(protein, carbs, fats),
      'description': notes,
    };
  }
}
