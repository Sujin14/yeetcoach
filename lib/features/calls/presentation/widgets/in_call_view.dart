import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/call_controller.dart';
import 'call_controls_bar.dart';
import 'call_party_avatar.dart';
import 'call_status_text.dart';
import 'local_video_preview.dart';
import 'remote_video_view.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Ringing, connected and finished states of a call, with the in-call controls.
/// Shared by the outgoing CallScreen and an answered IncomingCallScreen.
class InCallView extends StatelessWidget {
  final CallController controller;

  const InCallView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final nameStyle = _textTheme.titleLarge?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.onPrimary,
    );
    final statusStyle = _textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      color: AppColors.onPrimary.withValues(alpha: 0.85),
    );

    Widget status() => Obx(() => CallStatusText(
          phase: controller.phase.value,
          connectedAt: controller.connectedAt.value,
          finishedMessage: controller.finishedMessage.value,
          style: statusStyle,
        ));

    return Obx(() {
      final showRemoteVideo = controller.isVideo && controller.hasRemoteStream.value;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (showRemoteVideo) ...[
            RemoteVideoView(renderer: controller.remoteRenderer),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, AppSpacing.md, 140, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.party.name, style: nameStyle?.copyWith(fontSize: 20)),
                    const SizedBox(height: AppSpacing.xs),
                    status(),
                  ],
                ),
              ),
            ),
          ] else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 72),
                child: Column(
                  children: [
                    CallPartyAvatar(party: controller.party),
                    const SizedBox(height: 20),
                    Text(
                      controller.party.name,
                      textAlign: TextAlign.center,
                      style: nameStyle,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.isVideo ? 'Video call' : 'Audio call',
                      style: statusStyle?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.smd),
                    status(),
                  ],
                ),
              ),
            ),
          if (controller.isVideo)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              right: 16,
              child: LocalVideoPreview(
                renderer: controller.localRenderer,
                isCameraOff: controller.isCameraOff.value,
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: CallControlsBar(
                  isVideo: controller.isVideo,
                  isMuted: controller.isMuted.value,
                  isCameraOff: controller.isCameraOff.value,
                  isSpeakerOn: controller.isSpeakerOn.value,
                  onToggleMute: controller.toggleMute,
                  onEnd: controller.hangUp,
                  onToggleSpeaker: controller.toggleSpeaker,
                  onToggleCamera: controller.toggleCamera,
                  onSwitchCamera: controller.switchCamera,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
