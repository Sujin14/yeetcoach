import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workout_plan.dart';
import 'firestore_parsing.dart';

class WorkoutPlanModel extends WorkoutPlan {
  static const planType = 'workout';

  const WorkoutPlanModel({
    required super.id,
    required super.clientUid,
    required super.trainerId,
    required super.title,
    required super.description,
    required super.days,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WorkoutPlanModel.fromEntity(WorkoutPlan plan) {
    return WorkoutPlanModel(
      id: plan.id,
      clientUid: plan.clientUid,
      trainerId: plan.trainerId,
      title: plan.title,
      description: plan.description,
      days: plan.days,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
    );
  }

  /// [id] is the Firestore document id; falls back to an `id` field in [map].
  factory WorkoutPlanModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return WorkoutPlanModel(
      id: id ?? FirestoreParsing.toStringValue(map['id']),
      clientUid: FirestoreParsing.toStringValue(map['clientUid']),
      trainerId: FirestoreParsing.toStringValue(map['trainerId']),
      title: FirestoreParsing.toStringValue(map['title']),
      description: FirestoreParsing.toStringValue(map['description']),
      days: FirestoreParsing.toMapList(map['days']).map(WorkoutDayModel.fromMap).toList(),
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
      'days': days.map((day) => WorkoutDayModel.fromEntity(day).toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Full document read by YeetFit's PlanModel at users/{clientUid}/workouts/{id}, used on create.
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

  /// YeetFit lists exercises without day grouping, so days are flattened.
  /// difficulty, duration and category aren't collected by the form; YeetFit treats null as unset.
  Map<String, dynamic> _clientPlanFields() {
    return {
      'title': title,
      'type': planType,
      'userId': clientUid,
      'assignedBy': trainerId,
      'totalCalories': 0,
      'totalMacronutrients': <String, double>{'protein': 0.0, 'carbs': 0.0, 'fats': 0.0},
      'details': <String, dynamic>{
        'description': description,
        'difficulty': null,
        'duration': null,
        'category': null,
        'exercises': [
          for (final day in days)
            for (final exercise in day.exercises)
              ExerciseEntryModel.fromEntity(exercise).toClientPlanMap(day.dayLabel),
        ],
      },
    };
  }
}

class WorkoutDayModel extends WorkoutDay {
  const WorkoutDayModel({required super.dayLabel, required super.exercises});

  factory WorkoutDayModel.fromEntity(WorkoutDay day) {
    return WorkoutDayModel(dayLabel: day.dayLabel, exercises: day.exercises);
  }

  factory WorkoutDayModel.fromMap(Map<String, dynamic> map) {
    return WorkoutDayModel(
      dayLabel: FirestoreParsing.toStringValue(map['dayLabel']),
      exercises: FirestoreParsing.toMapList(map['exercises']).map(ExerciseEntryModel.fromMap).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayLabel': dayLabel,
      'exercises': exercises.map((exercise) => ExerciseEntryModel.fromEntity(exercise).toMap()).toList(),
    };
  }
}

class ExerciseEntryModel extends ExerciseEntry {
  const ExerciseEntryModel({
    required super.name,
    required super.sets,
    required super.restSeconds,
    super.reps,
    super.durationMinutes,
    super.notes,
    super.youtubeUrl,
  });

  factory ExerciseEntryModel.fromEntity(ExerciseEntry exercise) {
    return ExerciseEntryModel(
      name: exercise.name,
      sets: exercise.sets,
      restSeconds: exercise.restSeconds,
      reps: exercise.reps,
      durationMinutes: exercise.durationMinutes,
      notes: exercise.notes,
      youtubeUrl: exercise.youtubeUrl,
    );
  }

  factory ExerciseEntryModel.fromMap(Map<String, dynamic> map) {
    return ExerciseEntryModel(
      name: FirestoreParsing.toStringValue(map['name']),
      sets: FirestoreParsing.toInt(map['sets']),
      restSeconds: FirestoreParsing.toInt(map['restSeconds']),
      reps: FirestoreParsing.toIntOrNull(map['reps']),
      durationMinutes: FirestoreParsing.toIntOrNull(map['durationMinutes']),
      notes: FirestoreParsing.toStringValue(map['notes']),
      youtubeUrl: FirestoreParsing.toStringValue(map['youtubeUrl']),
    );
  }

  /// Optional fields are omitted when null to match the `reps?` / `durationMinutes?` schema.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      if (reps != null) 'reps': reps,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      'restSeconds': restSeconds,
      'notes': notes,
      'youtubeUrl': youtubeUrl,
    };
  }

  /// YeetFit's PlanExercise keys; a timed exercise shows its minutes in place of reps.
  Map<String, dynamic> toClientPlanMap(String dayLabel) {
    return {
      'name': name,
      'sets': sets,
      'reps': reps ?? durationMinutes,
      'repsType': reps != null ? 'reps' : (durationMinutes != null ? 'min' : ''),
      'restSeconds': restSeconds,
      'day': dayLabel,
      'description': notes,
      'videoUrl': youtubeUrl,
    };
  }
}
