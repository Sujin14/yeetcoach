import 'package:flutter/material.dart';
import 'package:yeetcoach/core/constants/legal_constants.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/core/utils/url_utils.dart';

import 'settings_group.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Legal',
      children: [
        SettingsTile(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          trailing: const Icon(Icons.open_in_new, color: AppColors.subtle),
          onTap: () => _open(kTermsUrl),
        ),
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          trailing: const Icon(Icons.open_in_new, color: AppColors.subtle),
          onTap: () => _open(kPrivacyUrl),
        ),
      ],
    );
  }

  Future<void> _open(String url) async {
    try {
      await launchUrlExternal(url);
    } catch (e) {
      logDebug('LegalSection: opening $url failed: $e');
      showErrorSnackbar('Could not open the link. Please try again.');
    }
  }
}
