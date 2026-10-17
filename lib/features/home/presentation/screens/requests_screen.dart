import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/coach_dashboard_controller.dart';
import '../widgets/dashboard_section_title.dart';
import '../widgets/list_tile_card_shimmer.dart';
import '../widgets/recent_request_tile.dart';
import '../widgets/request_card.dart';
import '../widgets/request_card_shimmer.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Pending requests to act on, then recently accepted or declined ones.
class RequestsScreen extends GetView<CoachDashboardController> {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        title: Obx(() {
          final count = controller.pendingRequests.length;
          return Row(
            children: [
              Text(
                'New Requests',
                style: _textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: _textTheme.labelSmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: const [
          _PendingSection(),
          _RecentSection(),
        ],
      ),
    );
  }
}

class _PendingSection extends GetView<CoachDashboardController> {
  const _PendingSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Widget body;
      if (controller.isLoadingRequests.value) {
        body = const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: ShimmerBase(
            child: Column(
              children: [RequestCardShimmer(), SizedBox(height: AppSpacing.sm), RequestCardShimmer()],
            ),
          ),
        );
      } else if (controller.pendingRequests.isEmpty) {
        body = const _NoPendingRequests();
      } else {
        body = Column(
          children: [
            for (final request in controller.pendingRequests)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                child: RequestCard(
                  key: ValueKey(request.id),
                  relationship: request,
                  isProcessing: controller.processingIds.contains(request.id),
                  onAccept: () =>
                      controller.respondToRequest(request.id, request.clientUid, accept: true),
                  onDecline: () =>
                      controller.respondToRequest(request.id, request.clientUid, accept: false),
                ),
              ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const DashboardSectionTitle('Pending'), body],
      );
    });
  }
}

class _NoPendingRequests extends StatelessWidget {
  const _NoPendingRequests();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Text(
              'No pending requests 🎉',
              textAlign: TextAlign.center,
              style: _textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "You're all caught up. New training requests from clients will appear here.",
              textAlign: TextAlign.center,
              style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hidden when there's nothing recent.
class _RecentSection extends GetView<CoachDashboardController> {
  const _RecentSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRecent.value) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionTitle('Recent'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ShimmerBase(
                child: Column(
                  children: [ListTileCardShimmer(), SizedBox(height: AppSpacing.sm), ListTileCardShimmer()],
                ),
              ),
            ),
          ],
        );
      }
      final recent = controller.recentDecisions;
      if (recent.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle('Recent'),
          for (final relationship in recent)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              child: RecentRequestTile(key: ValueKey(relationship.id), relationship: relationship),
            ),
        ],
      );
    });
  }
}
