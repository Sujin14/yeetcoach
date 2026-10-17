import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

import '../shimmer_base.dart';

/// Mirrors the client details screen: hero card, action buttons, the 2×2 stats grid
/// and the first section card.
class ClientDetailShimmer extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const ClientDetailShimmer({super.key, this.padding = const EdgeInsets.all(AppSpacing.md)});

  @override
  Widget build(BuildContext context) {
    const statCard = Expanded(child: ShimmerBox(width: double.infinity, height: 100, radius: 16));
    return ShimmerBase(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: double.infinity, height: 290, radius: 16),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ShimmerBox(width: double.infinity, height: 60, radius: 24)),
                SizedBox(width: AppSpacing.smd),
                Expanded(child: ShimmerBox(width: double.infinity, height: 60, radius: 24)),
                SizedBox(width: AppSpacing.smd),
                Expanded(child: ShimmerBox(width: double.infinity, height: 60, radius: 24)),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            ShimmerBox(width: 120, height: 18, radius: 6),
            SizedBox(height: 14),
            Row(children: [statCard, SizedBox(width: AppSpacing.smd), statCard]),
            SizedBox(height: AppSpacing.smd),
            Row(children: [statCard, SizedBox(width: AppSpacing.smd), statCard]),
            SizedBox(height: AppSpacing.lg),
            ShimmerBox(width: 140, height: 18, radius: 6),
            SizedBox(height: 14),
            ShimmerBox(width: double.infinity, height: 130, radius: 16),
          ],
        ),
      ),
    );
  }
}
