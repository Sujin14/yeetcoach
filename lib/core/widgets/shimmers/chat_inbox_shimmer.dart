import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

import '../shimmer_base.dart';

/// Mirrors ChatThreadTile: avatar, name and preview lines, timestamp.
class ChatInboxShimmer extends StatelessWidget {
  const ChatInboxShimmer({super.key});

  static const _itemCount = 6;

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: _itemCount,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
          child: Row(
            children: [
              ShimmerCircle(size: 48),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 14, radius: 4),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerBox(width: double.infinity, height: 12, radius: 4),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              ShimmerBox(width: 40, height: 10, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}
