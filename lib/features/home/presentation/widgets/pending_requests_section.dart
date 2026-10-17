import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/coach_dashboard_controller.dart';
import 'request_card.dart';
import 'request_card_shimmer.dart';
import 'section_header.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class PendingRequestsSection extends GetView<CoachDashboardController> {
  const PendingRequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRequests.value) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
          child: ShimmerBase(
            child: Column(
              children: [
                RequestCardShimmer(),
                SizedBox(height: AppSpacing.sm),
                RequestCardShimmer(),
              ],
            ),
          ),
        );
      }

      final requests = controller.pendingRequests;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.smd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader('New Requests', count: requests.length),
            const SizedBox(height: AppSpacing.sm),
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'No pending requests',
                  style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
                ),
              ),
            for (final request in requests)
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
        ),
      );
    });
  }
}
