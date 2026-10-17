import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/clients/data/repositories/client_profile_repository.dart';
import 'package:yeetcoach/features/clients/domain/entities/client_profile.dart';
import 'package:yeetcoach/features/clients/domain/repositories/i_client_profile_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/entities/group_session.dart';

class SessionController extends GetxController {
  SessionController({
    SessionRepository? repository,
    IClientProfileRepository? clients,
    FirebaseAuth? auth,
  })  : _repository = repository ?? SessionRepository(),
        _clients = clients ?? ClientProfileRepository(),
        _auth = auth ?? FirebaseAuth.instance;

  final SessionRepository _repository;
  final IClientProfileRepository _clients;
  final FirebaseAuth _auth;

  final RxList<GroupSession> sessions = <GroupSession>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isGlobal = false.obs;
  final RxList<String> selectedClientUids = <String>[].obs;
  final RxList<ClientProfile> myClients = <ClientProfile>[].obs;
  final RxBool isLoadingClients = true.obs;

  StreamSubscription<List<GroupSession>>? _subscription;
  StreamSubscription<List<ClientProfile>>? _clientsSub;
  var _reportedStreamError = false;

  @override
  void onInit() {
    super.onInit();
    loadMyClients();
    _subscription = _repository.streamUpcoming().listen(
      (list) {
        sessions.assignAll(list);
        isLoading.value = false;
      },
      onError: (Object error) {
        logDebug('SessionController: streamUpcoming failed: $error');
        isLoading.value = false;
        if (_reportedStreamError) return;
        _reportedStreamError = true;
        showErrorSnackbar('Could not load group sessions.');
      },
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _clientsSub?.cancel();
    super.onClose();
  }

  /// Clients whose currentCoachId is this coach. Photos come from the client profile stream.
  void loadMyClients() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      isLoadingClients.value = false;
      return;
    }
    _clientsSub ??= _clients.watchCoachClients(uid).listen(
      (clients) {
        myClients.assignAll(clients);
        selectedClientUids.removeWhere((id) => clients.every((client) => client.uid != id));
        isLoadingClients.value = false;
      },
      onError: (Object error) {
        logDebug('SessionController: loadMyClients failed: $error');
        isLoadingClients.value = false;
      },
    );
  }

  void toggleSelectAll() {
    if (selectedClientUids.length == myClients.length) {
      selectedClientUids.clear();
      return;
    }
    selectedClientUids.assignAll(myClients.map((client) => client.uid));
  }

  void toggleClient(String uid) {
    if (selectedClientUids.contains(uid)) {
      selectedClientUids.remove(uid);
      return;
    }
    selectedClientUids.add(uid);
  }

  /// Saves a session for every YeetFit user, or for [selectedClientUids] when it is not global.
  Future<bool> submitSession({
    required String title,
    required String meetLink,
    required DateTime scheduledAt,
    required int durationMinutes,
    String? description,
  }) {
    if (!isGlobal.value && selectedClientUids.isEmpty) {
      showErrorSnackbar('Pick at least one client or make the session global.');
      return Future.value(false);
    }
    return createSession(
      title: title,
      meetLink: meetLink,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      description: description,
      isGlobal: isGlobal.value,
      assignedClientUids: isGlobal.value ? const [] : selectedClientUids.toList(),
    );
  }

  Future<bool> createSession({
    required String title,
    required String meetLink,
    required DateTime scheduledAt,
    required int durationMinutes,
    required bool isGlobal,
    required List<String> assignedClientUids,
    String? description,
  }) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    try {
      await _repository.createSession(
        title: title,
        meetLink: meetLink,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        description: description,
        isGlobal: isGlobal,
        assignedClientUids: assignedClientUids,
      );
      this.isGlobal.value = false;
      selectedClientUids.clear();
      showSuccessSnackbar('Group session scheduled.');
      return true;
    } catch (error) {
      logDebug('SessionController: createSession failed: $error');
      showErrorSnackbar(_message(error, 'Could not schedule the session. Please try again.'));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteSession(String id) async {
    try {
      await _repository.deleteSession(id);
      showSuccessSnackbar('Session deleted.');
      return true;
    } catch (error) {
      logDebug('SessionController: deleteSession failed: $error');
      showErrorSnackbar(_message(error, 'Could not delete the session. Please try again.'));
      return false;
    }
  }

  String _message(Object error, String fallback) {
    if (error is StateError && error.message.isNotEmpty) return error.message;
    return fallback;
  }
}
