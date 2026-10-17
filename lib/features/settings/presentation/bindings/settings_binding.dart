import 'package:get/get.dart';
import 'package:yeetcoach/core/services/push_notification_service.dart';
import 'package:yeetcoach/features/coach/data/repositories/coach_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(
          CoachRepository(),
          SettingsRepository(),
          Get.find<PushNotificationService>(),
        ),
    );
  }
}
