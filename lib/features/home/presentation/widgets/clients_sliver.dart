import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import '../controllers/coach_dashboard_controller.dart';
import 'client_tile.dart';
import 'client_tile_shimmer.dart';
import 'empty_clients_view.dart';

class ClientsSliver extends GetView<CoachDashboardController> {
  const ClientsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingClients.value) {
        return SliverToBoxAdapter(
          child: ShimmerBase(
            child: Column(
              children: List.generate(5, (_) => const ClientTileShimmer()),
            ),
          ),
        );
      }

      final clients = controller.activeClients;
      if (clients.isEmpty) {
        return const SliverToBoxAdapter(child: EmptyClientsView());
      }

      return SliverList.separated(
        itemCount: clients.length,
        itemBuilder: (_, index) => ClientTile(client: clients[index]),
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
          color: AppColors.divider,
        ),
      );
    });
  }
}
