import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/features/training/domain/entities/training_relationship.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/coach_dashboard_controller.dart';
import 'request_card.dart';
import 'section_header.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Full accept/decline list, opened from the dashboard until requests get their own tab.
class PendingRequestsSheet extends GetView<CoachDashboardController> {
  /// When set, only this request is shown.
  final String? requestId;

  const PendingRequestsSheet({super.key, this.requestId});

  static void show({String? requestId}) {
    Get.bottomSheet<void>(
      PendingRequestsSheet(requestId: requestId),
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Flexible(
              child: Obx(() {
                final requests = _visibleRequests();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      requestId == null ? 'Pending Requests' : 'Training Request',
                      count: requests.length,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (requests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
                        child: Text(
                          requestId == null
                              ? 'No pending requests'
                              : 'This request has already been handled.',
                          style: _textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.subtle,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                          itemCount: requests.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (_, index) {
                            final request = requests[index];
                            return RequestCard(
                              key: ValueKey(request.id),
                              relationship: request,
                              isProcessing: controller.processingIds.contains(request.id),
                              onAccept: () => controller.respondToRequest(
                                request.id,
                                request.clientUid,
                                accept: true,
                              ),
                              onDecline: () => controller.respondToRequest(
                                request.id,
                                request.clientUid,
                                accept: false,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<TrainingRelationship> _visibleRequests() {
    final all = controller.pendingRequests;
    final id = requestId;
    return id == null ? all.toList() : all.where((request) => request.id == id).toList();
  }
}
