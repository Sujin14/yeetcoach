import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

/// Skeleton of one compact dashboard row: avatar, two text lines, trailing button.
/// Wrap a group of these in a single [ShimmerBase].
class ListTileCardShimmer extends StatelessWidget {
  final double avatarSize;

  const ListTileCardShimmer({super.key, this.avatarSize = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.smd, 10, AppSpacing.smd, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ShimmerCircle(size: avatarSize),
          const SizedBox(width: AppSpacing.smd),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 14, radius: 6),
                SizedBox(height: 6),
                ShimmerBox(width: 80, height: 12, radius: 6),
              ],
            ),
          ),
          const ShimmerBox(width: 64, height: 32, radius: 24),
        ],
      ),
    );
  }
}
