import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';
import '../widgets/about_section.dart';
import '../widgets/account_section.dart';
import '../widgets/danger_zone.dart';
import '../widgets/legal_section.dart';
import '../widgets/profile_card.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          // Navigator rather than Get.back, which closes an open snackbar instead of the route.
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: const [
            ProfileCard(),
            AccountSection(),
            LegalSection(),
            AboutSection(),
            DangerZone(),
          ],
        ),
      ),
    );
  }
}
