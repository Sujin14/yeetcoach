import 'dart:async';

import 'package:get/get.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/entities/group_session.dart';

class SessionController extends GetxController {
  SessionController({SessionRepository? repository}) : _repository = repository ?? SessionRepository();

  final SessionRepository _repository;

  final RxList<GroupSession> sessions = <GroupSession>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  StreamSubscription<List<GroupSession>>? _subscription;
  var _reportedStreamError = false;

  @override
  void onInit() {
    super.onInit();
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
    super.onClose();
  }

  Future<bool> createSession({
    required String title,
    required String meetLink,
    required DateTime scheduledAt,
    required int durationMinutes,
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
      );
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
