import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/section_header.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/widgets/staggered_entrance.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/coach_dashboard_controller.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'compact_request_tile.dart';
import 'list_tile_card_shimmer.dart';
import 'pending_requests_sheet.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Up to three pending requests; hidden entirely when there are none.
class CompactRequestsSection extends GetView<CoachDashboardController> {
  static const _maxVisible = 3;
  static const _entranceIndex = 5;

  const CompactRequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRequests.value) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
              child: SectionHeader(title: 'New Requests'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ShimmerBase(child: ListTileCardShimmer()),
            ),
          ],
        );
      }

      final requests = controller.pendingRequests;
      if (requests.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
            child: SectionHeader(
              title: 'New Requests',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${requests.length}',
                        style: _textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.notifications),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'View all',
                      style: _textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final (i, request) in requests.take(_maxVisible).indexed)
            StaggeredEntrance(
              key: ValueKey(request.id),
              index: _entranceIndex + i,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                child: CompactRequestTile(
                  request: request,
                  onView: () => PendingRequestsSheet.show(requestId: request.id),
                ),
              ),
            ),
        ],
      );
    });
  }
}
