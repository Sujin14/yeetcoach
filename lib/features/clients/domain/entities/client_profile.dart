import 'package:flutter/foundation.dart';

enum Gender { male, female, other }

enum FitnessLevel { beginner, intermediate, advanced }

enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive }

enum TrainingTime { morning, afternoon, evening, flexible }

enum FoodPreference { omnivore, vegetarian, vegan, keto, paleo, other }

@immutable
class ClientProfile {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int? age;
  final Gender? gender;
  final double? heightCm;
  final double? weightKg;
  final double? targetWeightKg;
  final List<String> medicalConditions;
  final List<String> injuries;
  final String? medications;
  final FitnessLevel? fitnessLevel;
  final int? yearsTraining;
  final ActivityLevel? activityLevel;
  final List<String> availableEquipment;
  final int? trainingDaysPerWeek;

  /// Weekday ints: 1 = Monday … 7 = Sunday.
  final List<int> trainingDays;
  final TrainingTime? preferredTrainingTime;
  final String? primaryGoal;
  final DateTime? targetDate;
  final FoodPreference? foodPreference;
  final List<String> foodAllergies;
  final String? currentCoachId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.targetWeightKg,
    List<String> medicalConditions = const [],
    List<String> injuries = const [],
    this.medications,
    this.fitnessLevel,
    this.yearsTraining,
    this.activityLevel,
    List<String> availableEquipment = const [],
    this.trainingDaysPerWeek,
    List<int> trainingDays = const [],
    this.preferredTrainingTime,
    this.primaryGoal,
    this.targetDate,
    this.foodPreference,
    List<String> foodAllergies = const [],
    this.currentCoachId,
    required this.createdAt,
    required this.updatedAt,
  })  : medicalConditions = List.unmodifiable(medicalConditions),
        injuries = List.unmodifiable(injuries),
        availableEquipment = List.unmodifiable(availableEquipment),
        foodAllergies = List.unmodifiable(foodAllergies),
        trainingDays = List.unmodifiable(trainingDays);

  ClientProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    List<String>? medicalConditions,
    List<String>? injuries,
    String? medications,
    FitnessLevel? fitnessLevel,
    int? yearsTraining,
    ActivityLevel? activityLevel,
    List<String>? availableEquipment,
    int? trainingDaysPerWeek,
    List<int>? trainingDays,
    TrainingTime? preferredTrainingTime,
    String? primaryGoal,
    DateTime? targetDate,
    FoodPreference? foodPreference,
    List<String>? foodAllergies,
    String? currentCoachId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ClientProfile(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        medicalConditions: medicalConditions ?? this.medicalConditions,
        injuries: injuries ?? this.injuries,
        medications: medications ?? this.medications,
        fitnessLevel: fitnessLevel ?? this.fitnessLevel,
        yearsTraining: yearsTraining ?? this.yearsTraining,
        activityLevel: activityLevel ?? this.activityLevel,
        availableEquipment: availableEquipment ?? this.availableEquipment,
        trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
        trainingDays: trainingDays ?? this.trainingDays,
        preferredTrainingTime:
            preferredTrainingTime ?? this.preferredTrainingTime,
        primaryGoal: primaryGoal ?? this.primaryGoal,
        targetDate: targetDate ?? this.targetDate,
        foodPreference: foodPreference ?? this.foodPreference,
        foodAllergies: foodAllergies ?? this.foodAllergies,
        currentCoachId: currentCoachId ?? this.currentCoachId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientProfile &&
          uid == other.uid &&
          name == other.name &&
          email == other.email &&
          profileImageUrl == other.profileImageUrl &&
          age == other.age &&
          gender == other.gender &&
          heightCm == other.heightCm &&
          weightKg == other.weightKg &&
          targetWeightKg == other.targetWeightKg &&
          listEquals(medicalConditions, other.medicalConditions) &&
          listEquals(injuries, other.injuries) &&
          medications == other.medications &&
          fitnessLevel == other.fitnessLevel &&
          yearsTraining == other.yearsTraining &&
          activityLevel == other.activityLevel &&
          listEquals(availableEquipment, other.availableEquipment) &&
          trainingDaysPerWeek == other.trainingDaysPerWeek &&
          listEquals(trainingDays, other.trainingDays) &&
          preferredTrainingTime == other.preferredTrainingTime &&
          primaryGoal == other.primaryGoal &&
          targetDate == other.targetDate &&
          foodPreference == other.foodPreference &&
          listEquals(foodAllergies, other.foodAllergies) &&
          currentCoachId == other.currentCoachId &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  // Object.hash accepts at most 20 arguments, so the 25 fields go through hashAll.
  @override
  int get hashCode => Object.hashAll([
        uid, name, email, profileImageUrl, age, gender,
        heightCm, weightKg, targetWeightKg,
        Object.hashAll(medicalConditions),
        Object.hashAll(injuries),
        medications, fitnessLevel, yearsTraining, activityLevel,
        Object.hashAll(availableEquipment),
        trainingDaysPerWeek, Object.hashAll(trainingDays), preferredTrainingTime, primaryGoal,
        targetDate, foodPreference,
        Object.hashAll(foodAllergies),
        currentCoachId, createdAt, updatedAt,
      ]);
}
