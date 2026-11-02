import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';
import '../../domain/entities/call_party.dart';
import '../../domain/entities/call_session.dart';
import '../../domain/entities/call_status.dart';
import '../../domain/entities/call_type.dart';
import '../../domain/entities/incoming_ring.dart';
import '../models/call_session_model.dart';
import 'call_exception.dart';

/// Reads and writes calls/{callId}.
class FirestoreCallService {
  final FirebaseFirestore _firestore;

  FirestoreCallService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _calls =>
      _firestore.collection(FirestoreCollections.calls);

  Future<String> createCall({
    required CallParty caller,
    required CallParty receiver,
    required CallType type,
  }) async {
    final ref = _calls.doc();
    await ref.set(
      CallSessionModel.toCreateMap(callId: ref.id, caller: caller, receiver: receiver, type: type),
    );
    return ref.id;
  }

  Stream<CallSession?> watchCall(String callId) {
    return _calls
        .doc(callId)
        .snapshots()
        .map((doc) => doc.exists ? CallSessionModel.fromSnapshot(doc) : null);
  }

  /// Caller name/photo live on the document but not on [CallSession].
  Future<({CallSession session, CallParty caller})?> getCallForAccept(String callId) async {
    final doc = await _calls.doc(callId).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? const <String, dynamic>{};
    final session = CallSessionModel.fromSnapshot(doc);
    final callerId = session.callerId;
    if (callerId.isEmpty) return null;
    final callerName = data['callerName'];
    final callerPhoto = data['callerPhoto'];
    return (
      session: session,
      caller: CallParty(
        uid: callerId,
        name: callerName is String && callerName.isNotEmpty ? callerName : 'Client',
        photoUrl: callerPhoto is String ? callerPhoto : '',
      ),
    );
  }

  /// Equality filters only, so no composite index is needed. The newest
  /// still-ringing call is chosen here.
  Stream<IncomingRing?> watchIncomingRing(String coachId) {
    return _calls
        .where('receiverId', isEqualTo: coachId)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .snapshots()
        .map((snapshot) {
      final rings = [
        for (final doc in snapshot.docs)
          if (IncomingRing.fromSnapshot(doc, coachId: coachId) case final ring?)
            if (ring.isStillRinging) ring,
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return rings.firstOrNull;
    });
  }

  /// Moves the call to [next] only from one of [allowedFrom], so a hang-up racing
  /// the client's answer (or the missed timeout) can't revive a finished call.
  Future<void> transition(
    String callId, {
    required CallStatus next,
    required Set<CallStatus> allowedFrom,
  }) {
    final ref = _calls.doc(callId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw const CallException('This call no longer exists.');
      final current = CallSessionModel.fromSnapshot(snapshot).status;
      if (current == next) return;
      if (!allowedFrom.contains(current)) throw const CallException('This call has already ended.');
      transaction.update(ref, {
        'status': next.name,
        if (next == CallStatus.active) 'startedAt': FieldValue.serverTimestamp(),
        if (next.isFinished) 'endedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
