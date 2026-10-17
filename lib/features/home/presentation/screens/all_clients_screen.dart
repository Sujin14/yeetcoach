import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../widgets/clients_sliver.dart';

/// Full client list. Uses the dashboard's CoachDashboardController, which stays
/// registered because this route is only pushed on top of /home.
class AllClientsScreen extends StatelessWidget {
  const AllClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Clients',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: const CustomScrollView(
        slivers: [
          ClientsSliver(),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ],
      ),
    );
  }
}
