import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'call_party.dart';
import 'call_status.dart';
import 'call_type.dart';

/// A call that is still ringing for this coach. [createdAt] is required so a
/// document left ringing forever is never presented.
@immutable
class IncomingRing {
  /// Matches YeetFit: a ringing call older than this is treated as abandoned.
  static const Duration maxAge = Duration(seconds: 60);

  final String callId;
  final CallType type;
  final CallParty caller;
  final DateTime createdAt;

  const IncomingRing({
    required this.callId,
    required this.type,
    required this.caller,
    required this.createdAt,
  });

  bool get isStillRinging => DateTime.now().difference(createdAt) < maxAge;

  /// Null when the document has no [createdAt] or is not addressed to [coachId].
  static IncomingRing? fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String coachId,
  }) {
    final data = doc.data();
    if (data == null) return null;
    if (data['receiverId'] != coachId) return null;
    if (data['status'] != CallStatus.ringing.name) return null;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final callerId = data['callerId'];
    if (createdAt == null || callerId is! String || callerId.isEmpty) return null;
    final callerName = data['callerName'];
    final callerPhoto = data['callerPhoto'];
    return IncomingRing(
      callId: doc.id,
      type: CallType.values.asNameMap()[data['type']] ?? CallType.audio,
      caller: CallParty(
        uid: callerId,
        name: callerName is String && callerName.isNotEmpty ? callerName : 'Client',
        photoUrl: callerPhoto is String ? callerPhoto : '',
      ),
      createdAt: createdAt,
    );
  }
}
