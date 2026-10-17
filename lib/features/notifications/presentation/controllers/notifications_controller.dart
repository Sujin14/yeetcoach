import 'dart:async';
import 'package:get/get.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../domain/entities/coach_notification.dart';

class NotificationsController extends GetxController {
  final _repo = NotificationsRepository();
  final notifications = <CoachNotification>[].obs;
  final isLoading = true.obs;
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _repo.streamUnread().listen(
      (list) {
        notifications.value = list;
        isLoading.value = false;
      },
      onError: (_) => isLoading.value = false,
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> markAllRead() => _repo.markAllRead();
  Future<void> clearAll() => _repo.deleteAll();
}
