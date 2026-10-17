import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/confirmation_dialog.dart';
import 'package:yeetcoach/core/widgets/shimmers/client_detail_shimmer.dart';
import 'package:yeetcoach/features/plan/domain/entities/plan_type.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/client_detail_controller.dart';
import '../widgets/assigned_plan_card.dart';
import '../widgets/call_client_buttons.dart';
import '../widgets/client_hero_card.dart';
import '../widgets/client_not_found.dart';
import '../widgets/client_section.dart';
import '../widgets/coach_notes_card.dart';
import '../widgets/nutrition_today_card.dart';
import '../widgets/plan_button.dart';
import '../widgets/todays_stats_grid.dart';
import '../widgets/training_days_card.dart';
import '../widgets/weekly_recovery_chart.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

void _openPlans(String uid, PlanType type) =>
    Get.toNamed(AppRoutes.planList, arguments: {'uid': uid, 'type': type});

class ClientDetailScreen extends GetView<ClientDetailController> {
  const ClientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
        title: Obx(() => Text(
              controller.client.value?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            )),
        actions: const [_ClientMenu()],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const ClientDetailShimmer();
        final client = controller.client.value;
        if (client == null) return const ClientNotFoundState();
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClientHeroCard(client: client),
              const SizedBox(height: 20),
              Obx(() => CallClientButtons(
                    isStartingCall: controller.isStartingCall.value,
                    onCall: controller.startCall,
                    onMessage: controller.openChat,
                  )),
              const SizedBox(height: 20),
              TrainingDaysCard(trainingDays: client.trainingDays),
              const ClientSection(title: "Today's Stats", child: TodaysStatsGrid()),
              const ClientSection(title: 'Nutrition Today', child: NutritionTodayCard()),
              ClientSection(
                title: 'Assigned Plan',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AssignedPlanCard(),
                    const SizedBox(height: AppSpacing.smd),
                    Row(
                      children: [
                        Expanded(
                          child: PlanButton(
                            label: 'Workout Plans',
                            icon: Icons.fitness_center_outlined,
                            filled: true,
                            onPressed: () => _openPlans(client.uid, PlanType.workout),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.smd),
                        Expanded(
                          child: PlanButton(
                            label: 'Diet Plans',
                            icon: Icons.restaurant_menu_outlined,
                            filled: false,
                            onPressed: () => _openPlans(client.uid, PlanType.diet),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const ClientSection(title: 'Weekly Recovery', child: WeeklyRecoveryChart()),
              const ClientSection(title: 'Notes', child: CoachNotesCard()),
            ],
          ),
        );
      }),
    );
  }
}

enum _ClientMenuAction { remove }

/// Three-dot menu; replaced by a spinner while the client is being removed.
class _ClientMenu extends GetView<ClientDetailController> {
  const _ClientMenu();

  Future<void> _confirmRemove(BuildContext context, String clientName) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove $clientName?',
      message: 'This will end the training relationship. '
          'The client will receive a notification.',
      confirmLabel: 'Remove',
    );
    if (confirmed) await controller.removeClient();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final client = controller.client.value;
      if (client == null) return const SizedBox.shrink();
      if (controller.isRemovingClient.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
            ),
          ),
        );
      }
      final name = client.name.trim().isEmpty ? 'this client' : client.name.trim();
      return PopupMenuButton<_ClientMenuAction>(
        icon: const Icon(Icons.more_vert),
        tooltip: 'More options',
        color: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (action) => switch (action) {
          _ClientMenuAction.remove => _confirmRemove(context, name),
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _ClientMenuAction.remove,
            child: Row(
              children: [
                const Icon(Icons.person_remove, size: 20, color: AppColors.error),
                const SizedBox(width: AppSpacing.smd),
                Text(
                  'Remove Client',
                  style: _textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
