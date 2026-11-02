import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeetcoach/core/services/call_native_service.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';

class CallSetupController extends GetxController {
  final Rxn<CallReadiness> readiness = Rxn<CallReadiness>();
  final RxBool loading = true.obs;
  final RxBool testScheduled = false.obs;
  final RxBool testPassed = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshReadiness();
  }

  Future<void> refreshReadiness() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final next = await CallNativeService.getCallReadiness();
      readiness.value = next;
      testPassed.value =
          prefs.getBool(CallNativeService.prefsCallSetupTestPassed) ?? false;
    } catch (e) {
      logDebug('CallSetupController: refresh failed: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> fix(String which) => CallNativeService.openCallSetting(which);

  Future<void> scheduleTest() async {
    testScheduled.value = true;
    await CallNativeService.scheduleTestCall();
  }

  Future<void> done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(CallNativeService.prefsCallSetupCompleted, true);
    Get.back();
  }

  void skip() => Get.back();
}
