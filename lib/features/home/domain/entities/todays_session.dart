import 'package:flutter/foundation.dart';

/// An active client whose workout plan from this coach has a day scheduled for today.
@immutable
class TodaysSession {
  final String clientUid;
  final String clientName;
  final String clientPhoto;
  final String planTitle;

  const TodaysSession({
    required this.clientUid,
    required this.clientName,
    this.clientPhoto = '',
    required this.planTitle,
  });

  TodaysSession copyWith({
    String? clientUid,
    String? clientName,
    String? clientPhoto,
    String? planTitle,
  }) {
    return TodaysSession(
      clientUid: clientUid ?? this.clientUid,
      clientName: clientName ?? this.clientName,
      clientPhoto: clientPhoto ?? this.clientPhoto,
      planTitle: planTitle ?? this.planTitle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaysSession &&
          other.clientUid == clientUid &&
          other.clientName == clientName &&
          other.clientPhoto == clientPhoto &&
          other.planTitle == planTitle;

  @override
  int get hashCode => Object.hash(clientUid, clientName, clientPhoto, planTitle);
}
