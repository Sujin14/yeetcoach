import '../entities/call_party.dart';
import '../entities/call_session.dart';
import '../entities/call_type.dart';
import '../entities/incoming_ring.dart';

abstract class ICallRepository {
  /// Creates calls/{callId} in the ringing state and returns its id.
  /// The onCallCreated Cloud Function pushes the incoming-call notification.
  Future<String> startCall({
    required CallParty caller,
    required CallParty receiver,
    required CallType type,
  });

  /// Emits null if the document is deleted.
  Stream<CallSession?> watchCall(String callId);

  /// One-shot read used after the coach accepts on the native call UI.
  Future<({CallSession session, CallParty caller})?> getCallForAccept(String callId);

  /// The newest call still ringing for [coachId], or null when none is.
  Stream<IncomingRing?> watchIncomingRing(String coachId);

  /// Answers a ringing call and stamps startedAt. Throws a CallException if it is no longer ringing.
  Future<void> acceptCall(String callId);

  /// Declines a ringing call. Throws a CallException if it is no longer ringing.
  Future<void> declineCall(String callId);

  /// Ends a ringing or active call and stamps endedAt. No-op if already ended.
  Future<void> endCall(String callId);

  /// Marks a still-ringing call missed. Throws a CallException if it was answered meanwhile.
  Future<void> markMissed(String callId);

  /// Metered API key from the getCallConfig Cloud Function, held in memory only.
  Future<String> getRealtimeApiKey();
}
