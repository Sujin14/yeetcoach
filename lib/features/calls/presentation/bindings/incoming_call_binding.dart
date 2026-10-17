import 'package:get/get.dart';
import '../../data/repositories/call_repository.dart';
import '../controllers/call_controller.dart';

class IncomingCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CallController>(CallController(CallRepository(), isIncoming: true));
  }
}
