import 'package:flutter/foundation.dart';

enum RelationshipStatus { pending, active, declined, ended }

enum EndedBy { coach, client }

@immutable
class TrainingRelationship {
  final String id;
  final String coachId;
  final String clientUid;
  final String coachName;

  /// Display details; YeetFit doesn't store them on the relationship, so they
  /// are filled in from users/{clientUid} when read.
  final String clientName;
  final String clientPhoto;

  final RelationshipStatus status;
  final DateTime requestedAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? endedAt;
  final EndedBy? endedBy;

  const TrainingRelationship({
    required this.id,
    required this.coachId,
    required this.clientUid,
    required this.coachName,
    required this.clientName,
    this.clientPhoto = '',
    required this.status,
    required this.requestedAt,
    this.updatedAt,
    this.acceptedAt,
    this.endedAt,
    this.endedBy,
  });

  TrainingRelationship copyWith({
    String? id,
    String? coachId,
    String? clientUid,
    String? coachName,
    String? clientName,
    String? clientPhoto,
    RelationshipStatus? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? endedAt,
    EndedBy? endedBy,
  }) =>
      TrainingRelationship(
        id: id ?? this.id,
        coachId: coachId ?? this.coachId,
        clientUid: clientUid ?? this.clientUid,
        coachName: coachName ?? this.coachName,
        clientName: clientName ?? this.clientName,
        clientPhoto: clientPhoto ?? this.clientPhoto,
        status: status ?? this.status,
        requestedAt: requestedAt ?? this.requestedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        endedAt: endedAt ?? this.endedAt,
        endedBy: endedBy ?? this.endedBy,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingRelationship &&
          id == other.id &&
          coachId == other.coachId &&
          clientUid == other.clientUid &&
          coachName == other.coachName &&
          clientName == other.clientName &&
          clientPhoto == other.clientPhoto &&
          status == other.status &&
          requestedAt == other.requestedAt &&
          updatedAt == other.updatedAt &&
          acceptedAt == other.acceptedAt &&
          endedAt == other.endedAt &&
          endedBy == other.endedBy;

  @override
  int get hashCode => Object.hash(
        id, coachId, clientUid, coachName, clientName, clientPhoto,
        status, requestedAt, updatedAt, acceptedAt, endedAt, endedBy,
      );
}
