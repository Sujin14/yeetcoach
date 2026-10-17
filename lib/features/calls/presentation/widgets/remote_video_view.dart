import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';

/// The client's camera, filling the screen.
class RemoteVideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;

  const RemoteVideoView({super.key, required this.renderer});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.onSurface,
      child: RTCVideoView(renderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
    );
  }
}
