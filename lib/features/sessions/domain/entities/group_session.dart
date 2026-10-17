import 'package:flutter/foundation.dart';

@immutable
class GroupSession {
  final String id;
  final String coachUid;
  final String title;
  final String meetLink;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? description;
  final DateTime createdAt;

  const GroupSession({
    required this.id,
    required this.coachUid,
    required this.title,
    required this.meetLink,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.description,
    required this.createdAt,
  });

  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  GroupSession copyWith({
    String? id,
    String? coachUid,
    String? title,
    String? meetLink,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? description,
    DateTime? createdAt,
  }) {
    return GroupSession(
      id: id ?? this.id,
      coachUid: coachUid ?? this.coachUid,
      title: title ?? this.title,
      meetLink: meetLink ?? this.meetLink,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupSession &&
          other.id == id &&
          other.coachUid == coachUid &&
          other.title == title &&
          other.meetLink == meetLink &&
          other.scheduledAt == scheduledAt &&
          other.durationMinutes == durationMinutes &&
          other.description == description &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        coachUid,
        title,
        meetLink,
        scheduledAt,
        durationMinutes,
        description,
        createdAt,
      );
}
