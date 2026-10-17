import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/widgets/staggered_entrance.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/coach_dashboard_controller.dart';
import 'client_activity_card.dart';
import 'dashboard_section_title.dart';

/// Horizontal strip of the most recently active clients; hidden when there are none.
class ClientActivitySection extends GetView<CoachDashboardController> {
  static const _maxVisible = 5;
  static const _stripHeight = 172.0;
  static const _entranceIndex = 6;

  const ClientActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRelationships.value) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionTitle('Client Activity'),
            _ClientActivityShimmer(),
          ],
        );
      }

      final relationships = controller.activeRelationships.take(_maxVisible).toList();
      if (relationships.isEmpty) return const SizedBox.shrink();
      // Read here so Obx tracks it; list items are built lazily outside this closure.
      final recoveryLevels = Map.of(controller.recoveryLevels);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle('Client Activity'),
          SizedBox(
            height: _stripHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
              itemCount: relationships.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.smd),
              itemBuilder: (_, index) {
                final relationship = relationships[index];
                return StaggeredEntrance(
                  key: ValueKey(relationship.id),
                  index: _entranceIndex + index,
                  child: ClientActivityCard(
                    name: relationship.clientName,
                    photoUrl: relationship.clientPhoto,
                    recoveryLevel: recoveryLevels[relationship.clientUid],
                    lastActive: CoachDashboardController.lastActivityOf(relationship),
                    onTap: () => Get.toNamed(
                      AppRoutes.clientDetails,
                      arguments: {'uid': relationship.clientUid},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _ClientActivityShimmer extends StatelessWidget {
  const _ClientActivityShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ClientActivitySection._stripHeight,
      child: ShimmerBase(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.smd),
          itemBuilder: (_, _) => Container(
            width: ClientActivityCard.width,
            padding: const EdgeInsets.fromLTRB(10, 14, 10, AppSpacing.smd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                ShimmerCircle(size: 56),
                SizedBox(height: AppSpacing.sm),
                ShimmerBox(width: 80, height: 14, radius: 6),
                SizedBox(height: AppSpacing.sm),
                ShimmerBox(width: 60, height: 18, radius: 24),
                SizedBox(height: AppSpacing.sm),
                ShimmerBox(width: 48, height: 10, radius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
