import 'package:flutter/foundation.dart';

@immutable
class WorkoutPlan {
  final String id;
  final String clientUid;
  final String trainerId;
  final String title;
  final String description;
  final List<WorkoutDay> days;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutPlan({
    required this.id,
    required this.clientUid,
    required this.trainerId,
    required this.title,
    required this.description,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
  });

  WorkoutPlan copyWith({
    String? id,
    String? clientUid,
    String? trainerId,
    String? title,
    String? description,
    List<WorkoutDay>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      clientUid: clientUid ?? this.clientUid,
      trainerId: trainerId ?? this.trainerId,
      title: title ?? this.title,
      description: description ?? this.description,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutPlan &&
          other.id == id &&
          other.clientUid == clientUid &&
          other.trainerId == trainerId &&
          other.title == title &&
          other.description == description &&
          listEquals(other.days, days) &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        clientUid,
        trainerId,
        title,
        description,
        Object.hashAll(days),
        createdAt,
        updatedAt,
      );
}

@immutable
class WorkoutDay {
  final String dayLabel;
  final List<ExerciseEntry> exercises;

  const WorkoutDay({required this.dayLabel, required this.exercises});

  WorkoutDay copyWith({String? dayLabel, List<ExerciseEntry>? exercises}) {
    return WorkoutDay(
      dayLabel: dayLabel ?? this.dayLabel,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDay && other.dayLabel == dayLabel && listEquals(other.exercises, exercises);

  @override
  int get hashCode => Object.hash(dayLabel, Object.hashAll(exercises));
}

@immutable
class ExerciseEntry {
  final String name;
  final String notes;
  final String youtubeUrl;
  final int sets;
  final int restSeconds;
  final int? reps;
  final int? durationMinutes;

  const ExerciseEntry({
    required this.name,
    required this.sets,
    required this.restSeconds,
    this.reps,
    this.durationMinutes,
    this.notes = '',
    this.youtubeUrl = '',
  });

  /// [reps] and [durationMinutes] take getters so they can be explicitly reset to null.
  ExerciseEntry copyWith({
    String? name,
    String? notes,
    String? youtubeUrl,
    int? sets,
    int? restSeconds,
    int? Function()? reps,
    int? Function()? durationMinutes,
  }) {
    return ExerciseEntry(
      name: name ?? this.name,
      notes: notes ?? this.notes,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      sets: sets ?? this.sets,
      restSeconds: restSeconds ?? this.restSeconds,
      reps: reps != null ? reps() : this.reps,
      durationMinutes: durationMinutes != null ? durationMinutes() : this.durationMinutes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseEntry &&
          other.name == name &&
          other.notes == notes &&
          other.youtubeUrl == youtubeUrl &&
          other.sets == sets &&
          other.restSeconds == restSeconds &&
          other.reps == reps &&
          other.durationMinutes == durationMinutes;

  @override
  int get hashCode => Object.hash(name, notes, youtubeUrl, sets, restSeconds, reps, durationMinutes);
}
