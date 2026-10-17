import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/features/calls/data/repositories/call_repository.dart';
import 'package:yeetcoach/features/coach/data/repositories/coach_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // Captured now: Get.arguments follows the top-most route.
    final args = (Get.arguments as Map?) ?? const {};
    final clientUid = switch (args) {
      {'clientUid': String uid} => uid,
      _ => '',
    };
    // Tagged per client so a notification can swap one open chat for another.
    Get.put<ChatController>(
      ChatController(ChatRepository(), CallRepository(), CoachRepository(), arguments: args),
      tag: AppRoutes.chatControllerTag(clientUid),
    );
  }
}
