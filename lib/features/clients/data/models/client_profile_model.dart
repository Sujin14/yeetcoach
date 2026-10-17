import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/client_profile.dart';

/// Parses an enum by `.name`. A missing field stays null so unset profile answers
/// are not replaced with a default; an unrecognised value falls back to [fallback].
String? _optionalString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Weekday ints. Firestore may store them as doubles, so each value is read as num.
List<int> _weekdayInts(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is num) item.toInt(),
  ];
}

T? _parseEnum<T extends Enum>(List<T> values, String? raw, T fallback) {
  if (raw == null) return null;
  return values.firstWhere(
    (e) => e.name == raw,
    orElse: () => fallback,
  );
}

class ClientProfileModel extends ClientProfile {
  ClientProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    super.profileImageUrl,
    super.age,
    super.gender,
    super.heightCm,
    super.weightKg,
    super.targetWeightKg,
    super.medicalConditions,
    super.injuries,
    super.medications,
    super.fitnessLevel,
    super.yearsTraining,
    super.activityLevel,
    super.availableEquipment,
    super.trainingDaysPerWeek,
    super.trainingDays,
    super.preferredTrainingTime,
    super.primaryGoal,
    super.targetDate,
    super.foodPreference,
    super.foodAllergies,
    super.currentCoachId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClientProfileModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClientProfileModel(
      uid: doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      profileImageUrl: _optionalString(data['profileImageUrl']) ??
          _optionalString(data['profilePicture']),
      age: (data['age'] as num?)?.toInt(),
      gender: _parseEnum(Gender.values, data['gender'] as String?, Gender.other),
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      targetWeightKg: (data['targetWeightKg'] as num?)?.toDouble(),
      medicalConditions: List<String>.from(
          (data['medicalConditions'] as List<dynamic>?) ?? []),
      injuries:
          List<String>.from((data['injuries'] as List<dynamic>?) ?? []),
      medications: data['medications'] as String?,
      fitnessLevel: _parseEnum(FitnessLevel.values,
          data['fitnessLevel'] as String?, FitnessLevel.beginner),
      yearsTraining: (data['yearsTraining'] as num?)?.toInt(),
      activityLevel: _parseEnum(ActivityLevel.values,
          data['activityLevel'] as String?, ActivityLevel.sedentary),
      availableEquipment: List<String>.from(
          (data['availableEquipment'] as List<dynamic>?) ?? []),
      trainingDaysPerWeek: (data['trainingDaysPerWeek'] as num?)?.toInt(),
      trainingDays: _weekdayInts(data['trainingDays']),
      preferredTrainingTime: _parseEnum(TrainingTime.values,
          data['preferredTrainingTime'] as String?, TrainingTime.flexible),
      primaryGoal: _optionalString(data['primaryGoal']) ?? _optionalString(data['goal']),
      targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
      foodPreference: _parseEnum(FoodPreference.values,
          data['foodPreference'] as String?, FoodPreference.omnivore),
      foodAllergies: List<String>.from(
          (data['foodAllergies'] as List<dynamic>?) ?? []),
      currentCoachId: data['currentCoachId'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'age': age,
        'gender': gender?.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'targetWeightKg': targetWeightKg,
        'medicalConditions': medicalConditions,
        'injuries': injuries,
        'medications': medications,
        'fitnessLevel': fitnessLevel?.name,
        'yearsTraining': yearsTraining,
        'activityLevel': activityLevel?.name,
        'availableEquipment': availableEquipment,
        'trainingDaysPerWeek': trainingDaysPerWeek,
        'trainingDays': trainingDays,
        'preferredTrainingTime': preferredTrainingTime?.name,
        'primaryGoal': primaryGoal,
        'targetDate':
            targetDate != null ? Timestamp.fromDate(targetDate!) : null,
        'foodPreference': foodPreference?.name,
        'foodAllergies': foodAllergies,
        'currentCoachId': currentCoachId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
