import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/training_relationship.dart';

class TrainingRelationshipModel extends TrainingRelationship {
  const TrainingRelationshipModel({
    required super.id,
    required super.coachId,
    required super.clientUid,
    required super.coachName,
    required super.clientName,
    super.clientPhoto,
    required super.status,
    required super.requestedAt,
    super.updatedAt,
    super.acceptedAt,
    super.endedAt,
    super.endedBy,
  });

  factory TrainingRelationshipModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    RelationshipStatus parseStatus(String? raw) {
      // Earlier YeetCoach builds wrote 'rejected' for a declined request.
      if (raw == 'rejected') return RelationshipStatus.declined;
      return RelationshipStatus.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => RelationshipStatus.pending,
      );
    }

    EndedBy? parseEndedBy(String? raw) {
      if (raw == null) return null;
      return EndedBy.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => EndedBy.coach,
      );
    }

    return TrainingRelationshipModel(
      id: doc.id,
      coachId: (data['coachId'] as String?) ?? '',
      // YeetFit writes clientUid; clientId is the field older YeetCoach docs used.
      clientUid: (data['clientUid'] as String?) ?? (data['clientId'] as String?) ?? '',
      coachName: (data['coachName'] as String?) ?? '',
      clientName: (data['clientName'] as String?) ?? '',
      status: parseStatus(data['status'] as String?),
      requestedAt:
          (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      endedBy: parseEndedBy(data['endedBy'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
        'coachId': coachId,
        'clientUid': clientUid,
        'coachName': coachName,
        'clientName': clientName,
        'status': status.name,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'acceptedAt':
            acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
        'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
        'endedBy': endedBy?.name,
      };
}
