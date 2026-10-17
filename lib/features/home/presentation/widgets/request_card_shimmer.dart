import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

/// Mirrors RequestCard: avatar, name and time, then the Decline / Accept buttons.
class RequestCardShimmer extends StatelessWidget {
  const RequestCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              ShimmerCircle(size: 48),
              SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 14, radius: 6),
                    SizedBox(height: 6),
                    ShimmerBox(width: 90, height: 12, radius: 6),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.smd),
          Row(
            children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 40, radius: 24)),
              SizedBox(width: AppSpacing.smd),
              Expanded(child: ShimmerBox(width: double.infinity, height: 40, radius: 24)),
            ],
          ),
        ],
      ),
    );
  }
}
