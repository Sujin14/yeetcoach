import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/widgets/staggered_entrance.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/coach_dashboard_controller.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'stat_chip.dart';

class QuickStatsRow extends GetView<CoachDashboardController> {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.smd, AppSpacing.md, 0),
      child: Obx(() {
        final isLoading = controller.isLoadingCoach.value ||
            controller.isLoadingRelationships.value ||
            controller.isLoadingRequests.value;
        if (isLoading) return const _QuickStatsShimmer();

        final rating = controller.coach.value?.averageRating ?? 0;
        return Row(
          children: [
            Expanded(
              child: StaggeredEntrance(
                index: 1,
                child: StatChip(
                  emoji: '👥',
                  value: controller.activeRelationships.length,
                  label: 'Clients',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: StaggeredEntrance(
                index: 2,
                child: StatChip(
                  emoji: '⏳',
                  value: controller.pendingRequests.length,
                  label: 'Requests',
                  onTap: () => Get.toNamed(AppRoutes.requests),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: StaggeredEntrance(
                index: 3,
                child: StatChip(
                  emoji: '⭐',
                  value: rating > 0 ? rating : null,
                  fractionDigits: 1,
                  label: 'Rating',
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _QuickStatsShimmer extends StatelessWidget {
  const _QuickStatsShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Container(
                height: 116,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
