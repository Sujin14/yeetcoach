import '../../domain/entities/call_party.dart';
import '../../domain/entities/call_session.dart';
import '../../domain/entities/call_status.dart';
import '../../domain/entities/call_type.dart';
import '../../domain/entities/incoming_ring.dart';
import '../../domain/repositories/i_call_repository.dart';
import '../datasources/firestore_call_service.dart';
import '../datasources/metered_config_service.dart';

class CallRepository implements ICallRepository {
  final FirestoreCallService _callService;
  final MeteredConfigService _configService;

  CallRepository({FirestoreCallService? callService, MeteredConfigService? configService})
      : _callService = callService ?? FirestoreCallService(),
        _configService = configService ?? MeteredConfigService();

  @override
  Future<String> startCall({
    required CallParty caller,
    required CallParty receiver,
    required CallType type,
  }) =>
      _callService.createCall(caller: caller, receiver: receiver, type: type);

  @override
  Stream<CallSession?> watchCall(String callId) => _callService.watchCall(callId);

  @override
  Future<({CallSession session, CallParty caller})?> getCallForAccept(String callId) =>
      _callService.getCallForAccept(callId);

  @override
  Stream<IncomingRing?> watchIncomingRing(String coachId) =>
      _callService.watchIncomingRing(coachId);

  @override
  Future<void> acceptCall(String callId) => _callService.transition(
        callId,
        next: CallStatus.active,
        allowedFrom: {CallStatus.ringing},
      );

  @override
  Future<void> declineCall(String callId) => _callService.transition(
        callId,
        next: CallStatus.declined,
        allowedFrom: {CallStatus.ringing},
      );

  @override
  Future<void> endCall(String callId) => _callService.transition(
        callId,
        next: CallStatus.ended,
        allowedFrom: {CallStatus.ringing, CallStatus.active},
      );

  @override
  Future<void> markMissed(String callId) => _callService.transition(
        callId,
        next: CallStatus.missed,
        allowedFrom: {CallStatus.ringing},
      );

  @override
  Future<String> getRealtimeApiKey() => _configService.getApiKey();
}
