import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/section_header.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/widgets/staggered_entrance.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/coach_dashboard_controller.dart';
import '../controllers/home_shell_controller.dart';
import 'list_tile_card_shimmer.dart';
import 'muted_info_card.dart';
import 'todays_client_tile.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Clients whose trainingDays include today.
class TodaysClientsSection extends GetView<CoachDashboardController> {
  static const _maxVisible = 3;
  static const _entranceIndex = 4;

  const TodaysClientsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasClients = controller.activeRelationships.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
            child: SectionHeader(
              title: "Today's Clients",
              trailing: hasClients
                  ? TextButton(
                      onPressed: () => HomeShellController.open(HomeTab.clients),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'See all clients',
                        style: _textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    )
                  : null,
            ),
          ),
          _buildBody(),
        ],
      );
    });
  }

  Widget _buildBody() {
    if (controller.isLoadingToday.value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ShimmerBase(
          child: Column(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                const ListTileCardShimmer(),
              ],
            ],
          ),
        ),
      );
    }

    final clients = controller.todaysClients;
    if (clients.isEmpty) {
      return StaggeredEntrance(
        index: _entranceIndex,
        child: MutedInfoCard(
          icon: Icons.event_available_outlined,
          message: controller.activeRelationships.isEmpty
              ? 'No clients are training today. Accept a request to start coaching.'
              : 'No clients are training today',
        ),
      );
    }

    final visible = clients.take(_maxVisible).toList();
    return Column(
      children: [
        for (var i = 0; i < visible.length; i++)
          StaggeredEntrance(
            key: ValueKey(visible[i].uid),
            index: _entranceIndex + i,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              child: TodaysClientTile(
                client: visible[i],
                onView: () => Get.toNamed(
                  AppRoutes.clientDetails,
                  arguments: {'uid': visible[i].uid},
                ),
              ),
            ),
          ),
      ],
    );
  }
}
