import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';

/// Order matches the bottom navigation bar.
enum HomeTab { home, clients, chats, challenges }

class HomeShellController extends GetxController {
  final Rx<HomeTab> currentTab = HomeTab.home.obs;

  @override
  void onInit() {
    super.onInit();
    // Lets a push notification open /home on a specific tab.
    if (Get.arguments case {'tab': HomeTab tab}) currentTab.value = tab;
  }

  void selectTab(HomeTab tab) => currentTab.value = tab;

  /// Shows [tab], closing any screens pushed on top of /home first.
  static void open(HomeTab tab) {
    if (!Get.isRegistered<HomeShellController>()) {
      Get.offAllNamed(AppRoutes.home, arguments: {'tab': tab});
      return;
    }
    if (Get.currentRoute != AppRoutes.home) {
      Get.until((route) => route.settings.name == AppRoutes.home);
    }
    Get.find<HomeShellController>().selectTab(tab);
  }
}
