import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import 'settings_group.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class AboutSection extends GetView<SettingsController> {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'About',
      children: [
        SettingsTile(
          icon: Icons.info_outline,
          title: 'App Version',
          trailing: Obx(() => Text(
                controller.appVersion.value,
                style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
              )),
        ),
        SettingsTile(
          icon: Icons.star_outline,
          title: 'Rate the App',
          onTap: () => controller.openLink(SettingsController.playStoreUrl),
        ),
        SettingsTile(
          icon: Icons.mail_outline,
          title: 'Contact Support',
          onTap: () => controller.openLink(SettingsController.supportEmailUrl),
        ),
      ],
    );
  }
}
