import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

/// Skeletons for the client details sections, each mirroring its loaded layout.

class _ShimmerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ShimmerCard({required this.child, this.padding = const EdgeInsets.all(AppSpacing.md)});

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

class ClientHeroShimmer extends StatelessWidget {
  const ClientHeroShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShimmerCard(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              ShimmerCircle(size: 88),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 160, height: 24, radius: 6),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerBox(width: 120, height: 13, radius: 6),
                    SizedBox(height: AppSpacing.smd),
                    ShimmerBox(width: 84, height: 22, radius: 24),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ShimmerCircle(size: 120),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: 100, height: 12, radius: 6),
        ],
      ),
    );
  }
}

class HealthStatCardShimmer extends StatelessWidget {
  const HealthStatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShimmerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCircle(size: 24),
          SizedBox(height: 10),
          ShimmerBox(width: 90, height: 18, radius: 6),
          SizedBox(height: 6),
          ShimmerBox(width: 48, height: 12, radius: 6),
        ],
      ),
    );
  }
}

class NutritionCardShimmer extends StatelessWidget {
  const NutritionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShimmerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 160, height: 32, radius: 6),
          SizedBox(height: 6),
          ShimmerBox(width: 110, height: 12, radius: 6),
          SizedBox(height: 14),
          ShimmerBox(width: double.infinity, height: 8, radius: 4),
          SizedBox(height: 14),
          ShimmerBox(width: 220, height: 13, radius: 6),
        ],
      ),
    );
  }
}

class AssignedPlanShimmer extends StatelessWidget {
  const AssignedPlanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShimmerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 180, height: 18, radius: 6),
          SizedBox(height: 6),
          ShimmerBox(width: 100, height: 12, radius: 6),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(width: 200, height: 14, radius: 6),
          SizedBox(height: 10),
          ShimmerBox(width: 170, height: 14, radius: 6),
          SizedBox(height: 10),
          ShimmerBox(width: 150, height: 14, radius: 6),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(width: 120, height: 36, radius: 24),
        ],
      ),
    );
  }
}

class WeeklyRecoveryShimmer extends StatelessWidget {
  const WeeklyRecoveryShimmer({super.key});

  static const _barHeights = [60.0, 90.0, 40.0, 110.0, 75.0, 50.0, 95.0];

  @override
  Widget build(BuildContext context) {
    return _ShimmerCard(
      child: SizedBox(
        height: 180,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final height in _barHeights) ShimmerBox(width: 18, height: height, radius: 6),
          ],
        ),
      ),
    );
  }
}

class CoachNotesShimmer extends StatelessWidget {
  const CoachNotesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShimmerCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14, radius: 6),
                SizedBox(height: AppSpacing.sm),
                ShimmerBox(width: 180, height: 14, radius: 6),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.smd),
          ShimmerCircle(size: 24),
        ],
      ),
    );
  }
}
