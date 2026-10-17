import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_type.dart';

class ChallengeModel extends Challenge {
  ChallengeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.targetValue,
    required super.targetUnit,
    required super.durationDays,
    required super.startDate,
    required super.endDate,
    required super.coachId,
    required super.assignedTo,
    required super.createdAt,
    required super.status,
    super.participantCount,
  });

  /// Falls back to YeetFit's `metric` / `goal` names for challenges created in the console.
  factory ChallengeModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final type = ChallengeType.tryParse(data['type'] ?? data['metric']) ?? ChallengeType.steps;
    final durationDays = (data['durationDays'] as num?)?.toInt() ?? 0;
    final startDate = (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    return ChallengeModel(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Challenge',
      description: (data['description'] as String?) ?? '',
      type: type,
      targetValue: ((data['targetValue'] ?? data['goal']) as num?)?.toInt() ?? 0,
      targetUnit: (data['targetUnit'] as String?) ?? type.unit,
      durationDays: durationDays,
      startDate: startDate,
      endDate: (data['endDate'] as Timestamp?)?.toDate() ??
          startDate.add(Duration(days: durationDays)),
      coachId: (data['coachId'] as String?) ?? '',
      assignedTo: List<String>.from((data['assignedTo'] as List<dynamic>?) ?? const []),
      // serverTimestamp() reads back as null until the write is acknowledged.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ChallengeStatus.parse(data['status']),
      participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// `metric`, `goal` and `participantCount` are the fields YeetFit's challenge
  /// list, join flow and progress sync read.
  static Map<String, dynamic> createMap({required String coachId, required NewChallenge challenge}) {
    final day = challenge.startDay;
    final startDate = DateTime(day.year, day.month, day.day);
    // Calendar-day arithmetic keeps local midnight across DST changes.
    final endDate = DateTime(day.year, day.month, day.day + challenge.durationDays);
    return {
      'title': challenge.title,
      'description': challenge.description,
      'type': challenge.type.name,
      'metric': challenge.type.name,
      'targetValue': challenge.targetValue,
      'goal': challenge.targetValue,
      'targetUnit': challenge.type.unit,
      'durationDays': challenge.durationDays,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'coachId': coachId,
      'assignedTo': challenge.assignedTo,
      'createdAt': FieldValue.serverTimestamp(),
      'status': ChallengeStatus.active.name,
      'participantCount': 0,
    };
  }
}
