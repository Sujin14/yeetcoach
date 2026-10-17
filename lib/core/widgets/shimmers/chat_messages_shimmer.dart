import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

import '../shimmer_base.dart';

/// Mirrors the chat message list: bubbles alternating between the client (left) and coach (right).
class ChatMessagesShimmer extends StatelessWidget {
  const ChatMessagesShimmer({super.key});

  static const _bubbleWidths = [180.0, 220.0, 140.0, 240.0, 160.0, 200.0, 120.0];

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: ListView.builder(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _bubbleWidths.length,
        itemBuilder: (_, index) => Align(
          alignment: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: ShimmerBox(width: _bubbleWidths[index], height: 44, radius: 16),
          ),
        ),
      ),
    );
  }
}
