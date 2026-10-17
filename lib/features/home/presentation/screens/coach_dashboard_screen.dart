import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/widgets/staggered_entrance.dart';
import '../controllers/coach_dashboard_controller.dart';
import '../widgets/client_activity_section.dart';
import '../widgets/compact_requests_section.dart';
import '../widgets/dashboard_toolbar.dart';
import '../widgets/greeting_header.dart';
import '../widgets/group_sessions_section.dart';
import '../widgets/motivation_card.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/todays_clients_section.dart';

class CoachDashboardScreen extends GetView<CoachDashboardController> {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<CoachDashboardController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DashboardToolbar(
        actions: [
          Obx(() {
            final count = dashboard.pendingRequests.length;
            return IconButton(
              tooltip: 'Requests',
              icon: Badge(
                isLabelVisible: count > 0,
                backgroundColor: AppColors.error,
                textColor: AppColors.onPrimary,
                label: Text(count > 99 ? '99+' : '$count'),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => Get.toNamed(AppRoutes.notifications),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: const [
            GreetingHeader(),
            QuickStatsRow(),
            TodaysClientsSection(),
            GroupSessionsSection(),
            CompactRequestsSection(),
            ClientActivitySection(),
            StaggeredEntrance(index: 7, child: MotivationCard()),
          ],
        ),
      ),
    );
  }
}
