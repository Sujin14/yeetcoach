import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yeetcoach/features/plan/data/models/firestore_parsing.dart';
import '../../domain/entities/group_session.dart';

class GroupSessionModel extends GroupSession {
  const GroupSessionModel({
    required super.id,
    required super.coachUid,
    required super.title,
    required super.meetLink,
    required super.scheduledAt,
    super.durationMinutes = 60,
    super.description,
    required super.createdAt,
    super.isGlobal = false,
    super.assignedClientUids = const [],
  });

  factory GroupSessionModel.fromMap(String id, Map<String, dynamic> map) {
    final description = FirestoreParsing.toStringValue(map['description']).trim();
    return GroupSessionModel(
      id: id,
      coachUid: FirestoreParsing.toStringValue(map['coachUid']),
      title: FirestoreParsing.toStringValue(map['title']),
      meetLink: FirestoreParsing.toStringValue(map['meetLink']),
      scheduledAt: FirestoreParsing.toDateTime(map['scheduledAt']),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
      description: description.isEmpty ? null : description,
      createdAt: FirestoreParsing.toDateTime(map['createdAt']),
      isGlobal: map['isGlobal'] as bool? ?? false,
      assignedClientUids: _clientUids(map['assignedClientUids']),
    );
  }

  /// Writes all fields that YeetFit reads. [trainerName] and [trainerPhoto]
  /// are fetched from the coach profile by the repository before calling this.
  Map<String, dynamic> toMap({
    required String trainerName,
    required String trainerPhoto,
  }) {
    final endsAt = scheduledAt.add(Duration(minutes: durationMinutes));
    return {
      'coachUid': coachUid,
      'trainerId': coachUid,
      'trainerName': trainerName,
      'trainerPhoto': trainerPhoto,
      'title': title,
      'meetLink': meetLink,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'durationMinutes': durationMinutes,
      'isGlobal': isGlobal,
      'assignedClientUids': assignedClientUids,
      'createdAt': Timestamp.fromDate(createdAt),
      if (description != null && description!.isNotEmpty) 'description': description,
    };
  }
}

List<String> _clientUids(Object? value) {
  if (value is! List) return const [];
  return [
    for (final uid in value)
      if (uid is String && uid.trim().isNotEmpty) uid,
  ];
}
