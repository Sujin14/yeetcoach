import 'package:get/get.dart';
import 'package:yeetcoach/features/challenges/presentation/bindings/challenges_binding.dart';
import 'package:yeetcoach/features/chat/presentation/bindings/chat_inbox_binding.dart';
import 'package:yeetcoach/features/sessions/presentation/controllers/session_controller.dart';
import 'package:yeetcoach/features/notifications/presentation/controllers/notifications_controller.dart';
import '../controllers/home_shell_controller.dart';
import 'coach_dashboard_binding.dart';

/// Registers the controllers of all five tabs, which live as long as /home.
class HomeShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeShellController>(HomeShellController());
    Get.put(NotificationsController());
    Get.lazyPut(() => SessionController());
    CoachDashboardBinding().dependencies();
    ChatInboxBinding().dependencies();
    ChallengesBinding().dependencies();
  }
}
