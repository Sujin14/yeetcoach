import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';

/// App bar for the dashboard; the greeting lives in the header card below it.
class DashboardToolbar extends StatelessWidget implements PreferredSizeWidget {
  /// Shown before the settings button.
  final List<Widget> actions;

  const DashboardToolbar({super.key, this.actions = const []});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      title: const Text(
        'YeetCoach',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      actions: [
        ...actions,
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Get.toNamed(AppRoutes.settings),
        ),
      ],
    );
  }
}
