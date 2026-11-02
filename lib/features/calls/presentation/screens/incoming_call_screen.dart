import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import '../controllers/call_controller.dart';
import '../widgets/in_call_view.dart';
import '../widgets/incoming_call_view.dart';

/// A call from a client: Answer / Decline when opened without auto-answer,
/// otherwise the in-call UI (native already accepted).
class IncomingCallScreen extends GetView<CallController> {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Back declines a ringing call and hangs up an answered one, so the client is never left waiting.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final isRinging =
            controller.phase.value == CallPhase.incoming && !controller.isAnswering.value;
        isRinging ? controller.decline() : controller.hangUp();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.primary,
          body: Obx(() {
            if (controller.phase.value != CallPhase.incoming) {
              return InCallView(controller: controller);
            }
            return IncomingCallView(
              caller: controller.party,
              isVideo: controller.isVideo,
              isAnswering: controller.isAnswering.value,
              onAnswer: controller.answer,
              onDecline: controller.decline,
            );
          }),
        ),
      ),
    );
  }
}
