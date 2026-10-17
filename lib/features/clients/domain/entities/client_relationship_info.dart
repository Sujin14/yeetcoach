import 'package:flutter/foundation.dart';

/// The parts of training_relationships/{clientUid}_{coachUid} shown on client details.
@immutable
class ClientRelationshipInfo {
  final String id;
  final DateTime? trainingSince;

  const ClientRelationshipInfo({
    required this.id,
    this.trainingSince,
  });

  ClientRelationshipInfo copyWith({String? id, DateTime? trainingSince}) {
    return ClientRelationshipInfo(
      id: id ?? this.id,
      trainingSince: trainingSince ?? this.trainingSince,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientRelationshipInfo &&
          other.id == id &&
          other.trainingSince == trainingSince;

  @override
  int get hashCode => Object.hash(id, trainingSince);
}
