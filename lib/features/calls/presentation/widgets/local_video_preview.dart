import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';

/// Picture-in-picture of the coach's own camera.
class LocalVideoPreview extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool isCameraOff;

  const LocalVideoPreview({super.key, required this.renderer, required this.isCameraOff});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.onSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.3)),
      ),
      child: isCameraOff
          ? const Icon(Icons.videocam_off, color: AppColors.onPrimary)
          : RTCVideoView(
              renderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
    );
  }
}
