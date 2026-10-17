import 'package:get/get.dart';
import '../../data/repositories/chat_repository.dart';
import '../controllers/chat_inbox_controller.dart';

class ChatInboxBinding extends Bindings {
  @override
  void dependencies() {
    // The Chats tab registers it with /home; replacing it from /home/chats would
    // delete the tab's controller when that route pops.
    if (Get.isRegistered<ChatInboxController>()) return;
    Get.put<ChatInboxController>(ChatInboxController(ChatRepository()));
  }
}
