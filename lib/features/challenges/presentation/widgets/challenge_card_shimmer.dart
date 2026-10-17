import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

/// Mirrors [ChallengeCard]: title, target row, progress bar, avatars, two buttons.
class ChallengeCardShimmer extends StatelessWidget {
  const ChallengeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: const ShimmerBase(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerCircle(size: 22),
                SizedBox(width: AppSpacing.sm),
                ShimmerBox(width: 180, height: 18, radius: 6),
              ],
            ),
            SizedBox(height: AppSpacing.smd),
            Row(
              children: [
                ShimmerBox(width: 140, height: 14, radius: 6),
                Spacer(),
                ShimmerBox(width: 56, height: 20, radius: 12),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            ShimmerBox(width: double.infinity, height: 6, radius: 4),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                ShimmerBox(width: 70, height: 12, radius: 6),
                Spacer(),
                ShimmerBox(width: 70, height: 12, radius: 6),
              ],
            ),
            SizedBox(height: 14),
            Row(
              children: [
                ShimmerBox(width: 70, height: 12, radius: 6),
                SizedBox(width: AppSpacing.sm),
                ShimmerCircle(size: 28),
                SizedBox(width: AppSpacing.xs),
                ShimmerCircle(size: 28),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: ShimmerBox(width: double.infinity, height: 40, radius: 24)),
                SizedBox(width: AppSpacing.smd),
                Expanded(child: ShimmerBox(width: double.infinity, height: 40, radius: 24)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
