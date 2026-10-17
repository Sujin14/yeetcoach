import 'package:flutter/foundation.dart';
import 'challenge_type.dart';

@immutable
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  final String targetUnit;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final String coachId;
  final List<String> assignedTo;
  final DateTime createdAt;
  final ChallengeStatus status;

  /// Maintained by YeetFit when users join or leave.
  final int participantCount;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.targetUnit,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.coachId,
    required List<String> assignedTo,
    required this.createdAt,
    required this.status,
    this.participantCount = 0,
  }) : assignedTo = List.unmodifiable(assignedTo);

  /// Ended by the coach, or past its end date (nothing flips the status automatically).
  bool isEndedAt(DateTime now) => status == ChallengeStatus.ended || !now.isBefore(endDate);

  bool hasStartedAt(DateTime now) => !now.isBefore(startDate);

  /// Whole days until [endDate], rounded up; 0 once ended.
  int daysLeftAt(DateTime now) {
    if (isEndedAt(now)) return 0;
    final hours = endDate.difference(now).inHours;
    return ((hours + 23) ~/ 24).clamp(0, durationDays);
  }

  /// Whole days until [startDate], rounded up; 0 once started.
  int daysUntilStartAt(DateTime now) {
    if (hasStartedAt(now)) return 0;
    return (startDate.difference(now).inHours + 23) ~/ 24;
  }

  /// Fraction of the planned duration that has passed, 0–1.
  double progressAt(DateTime now) {
    final total = durationDays * Duration.minutesPerDay;
    if (total <= 0) return 1;
    final effectiveNow = now.isAfter(endDate) ? endDate : now;
    return (effectiveNow.difference(startDate).inMinutes / total).clamp(0.0, 1.0);
  }

  Challenge copyWith({
    String? title,
    String? description,
    ChallengeType? type,
    int? targetValue,
    String? targetUnit,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? assignedTo,
    ChallengeStatus? status,
    int? participantCount,
  }) {
    return Challenge(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coachId: coachId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
      status: status ?? this.status,
      participantCount: participantCount ?? this.participantCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Challenge &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          type == other.type &&
          targetValue == other.targetValue &&
          targetUnit == other.targetUnit &&
          durationDays == other.durationDays &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          coachId == other.coachId &&
          listEquals(assignedTo, other.assignedTo) &&
          createdAt == other.createdAt &&
          status == other.status &&
          participantCount == other.participantCount;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        type,
        targetValue,
        targetUnit,
        durationDays,
        startDate,
        endDate,
        coachId,
        Object.hashAll(assignedTo),
        createdAt,
        status,
        participantCount,
      );
}

/// Input for creating a challenge; dates are computed by the data layer.
@immutable
class NewChallenge {
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  final int durationDays;

  /// Local calendar day the challenge starts; it runs from that day's midnight.
  final DateTime startDay;
  final List<String> assignedTo;

  NewChallenge({
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.durationDays,
    required this.startDay,
    required List<String> assignedTo,
  }) : assignedTo = List.unmodifiable(assignedTo);
}

/// Name and photo of an assigned client, read from users/{uid}.
@immutable
class ChallengeMember {
  final String uid;
  final String name;
  final String photoUrl;

  const ChallengeMember({required this.uid, required this.name, required this.photoUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeMember && uid == other.uid && name == other.name && photoUrl == other.photoUrl;

  @override
  int get hashCode => Object.hash(uid, name, photoUrl);
}
