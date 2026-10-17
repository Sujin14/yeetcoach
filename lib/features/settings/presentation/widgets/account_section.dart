import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'settings_group.dart';

class AccountSection extends GetView<SettingsController> {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Account',
      children: [
        if (controller.canChangePassword)
          SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: controller.sendPasswordReset,
          ),
        Obx(() => SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Client requests and messages',
              onTap: () => controller.setNotificationsEnabled(!controller.notificationsEnabled.value),
              trailing: _ToggleSwitch(
                value: controller.notificationsEnabled.value,
                onChanged: controller.setNotificationsEnabled,
              ),
            )),
        Obx(() => SettingsTile(
              icon: Icons.call_outlined,
              title: 'Call Notifications',
              subtitle: 'Alerts for incoming client calls',
              onTap: () =>
                  controller.setCallNotificationsEnabled(!controller.callNotificationsEnabled.value),
              trailing: _ToggleSwitch(
                value: controller.callNotificationsEnabled.value,
                onChanged: controller.setCallNotificationsEnabled,
              ),
            )),
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          onTap: () => Get.toNamed(AppRoutes.terms),
        ),
      ],
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      activeThumbColor: AppColors.onPrimary,
      activeTrackColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
