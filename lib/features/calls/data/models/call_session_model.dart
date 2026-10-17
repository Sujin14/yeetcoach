import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/call_party.dart';
import '../../domain/entities/call_session.dart';
import '../../domain/entities/call_status.dart';
import '../../domain/entities/call_type.dart';

/// Firestore mapping for calls/{callId}, shared with YeetFit's CallSessionModel.
class CallSessionModel extends CallSession {
  const CallSessionModel({
    required super.id,
    required super.callerId,
    required super.receiverId,
    required super.channelId,
    required super.type,
    required super.status,
    super.startedAt,
    super.endedAt,
  });

  factory CallSessionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final channelId = data['channelId'] as String?;
    return CallSessionModel(
      id: doc.id,
      callerId: data['callerId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      channelId: channelId == null || channelId.isEmpty ? doc.id : channelId,
      type: CallType.values.asNameMap()[data['type']] ?? CallType.audio,
      // An unrecognised status is treated as finished so the screen never hangs on it.
      status: CallStatus.values.asNameMap()[data['status']] ?? CallStatus.ended,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// YeetFit's incoming-call listener ignores ringing calls without createdAt,
  /// joins the room in channelId, and shows callerName / callerPhoto.
  static Map<String, dynamic> toCreateMap({
    required String callId,
    required CallParty caller,
    required CallParty receiver,
    required CallType type,
  }) {
    return {
      'callerId': caller.uid,
      'callerName': caller.name,
      'callerPhoto': caller.photoUrl,
      'receiverId': receiver.uid,
      'receiverName': receiver.name,
      'receiverPhoto': receiver.photoUrl,
      'channelId': callId,
      'type': type.name,
      'status': CallStatus.ringing.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
