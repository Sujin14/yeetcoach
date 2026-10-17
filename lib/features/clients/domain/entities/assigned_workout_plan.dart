import 'package:flutter/foundation.dart';

/// An exercise as stored on the client's copy of a plan (users/{uid}/workouts).
@immutable
class AssignedExercise {
  final String name;
  final String day;
  final int? sets;
  final int? reps;

  /// 'reps' or 'min'; empty when neither was set.
  final String repsType;

  const AssignedExercise({
    required this.name,
    this.day = '',
    this.sets,
    this.reps,
    this.repsType = '',
  });

  AssignedExercise copyWith({String? name, String? day, int? sets, int? reps, String? repsType}) {
    return AssignedExercise(
      name: name ?? this.name,
      day: day ?? this.day,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      repsType: repsType ?? this.repsType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignedExercise &&
          other.name == name &&
          other.day == day &&
          other.sets == sets &&
          other.reps == reps &&
          other.repsType == repsType;

  @override
  int get hashCode => Object.hash(name, day, sets, reps, repsType);
}

/// The client's most recently assigned workout plan.
@immutable
class AssignedWorkoutPlan {
  final String id;
  final String title;
  final DateTime? createdAt;
  final List<AssignedExercise> exercises;

  AssignedWorkoutPlan({
    required this.id,
    required this.title,
    this.createdAt,
    List<AssignedExercise> exercises = const [],
  }) : exercises = List.unmodifiable(exercises);

  AssignedWorkoutPlan copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<AssignedExercise>? exercises,
  }) {
    return AssignedWorkoutPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignedWorkoutPlan &&
          other.id == id &&
          other.title == title &&
          other.createdAt == createdAt &&
          listEquals(other.exercises, exercises);

  @override
  int get hashCode => Object.hash(id, title, createdAt, Object.hashAll(exercises));
}
