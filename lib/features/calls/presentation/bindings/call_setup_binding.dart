import 'package:get/get.dart';
import '../controllers/call_setup_controller.dart';

class CallSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CallSetupController());
  }
}
