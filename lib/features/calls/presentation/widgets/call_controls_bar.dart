import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'call_control_button.dart';

/// Audio: Mute / End / Speaker. Video: Mute / Camera / End / Switch camera.
class CallControlsBar extends StatelessWidget {
  final bool isVideo;
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final VoidCallback onToggleMute;
  final VoidCallback onEnd;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleCamera;
  final VoidCallback onSwitchCamera;

  const CallControlsBar({
    super.key,
    required this.isVideo,
    required this.isMuted,
    required this.isCameraOff,
    required this.isSpeakerOn,
    required this.onToggleMute,
    required this.onEnd,
    required this.onToggleSpeaker,
    required this.onToggleCamera,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    final mute = CallControlButton(
      icon: isMuted ? Icons.mic_off : Icons.mic,
      label: isMuted ? 'Unmute' : 'Mute',
      isActive: isMuted,
      onPressed: onToggleMute,
    );
    final end = CallControlButton(
      icon: Icons.call_end,
      label: 'End',
      size: 72,
      backgroundColor: AppColors.error,
      onPressed: onEnd,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isVideo
          ? [
              mute,
              CallControlButton(
                icon: isCameraOff ? Icons.videocam_off : Icons.videocam,
                label: isCameraOff ? 'Camera on' : 'Camera off',
                isActive: isCameraOff,
                onPressed: onToggleCamera,
              ),
              end,
              CallControlButton(
                icon: Icons.cameraswitch_outlined,
                label: 'Switch',
                onPressed: isCameraOff ? null : onSwitchCamera,
              ),
            ]
          : [
              mute,
              end,
              CallControlButton(
                icon: isSpeakerOn ? Icons.volume_up : Icons.hearing,
                label: isSpeakerOn ? 'Speaker' : 'Earpiece',
                isActive: isSpeakerOn,
                onPressed: onToggleSpeaker,
              ),
            ],
    );
  }
}
