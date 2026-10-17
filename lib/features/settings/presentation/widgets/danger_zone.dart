import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/confirmation_dialog.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class DangerZone extends GetView<SettingsController> {
  const DangerZone({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      message: "You'll need to sign in again to manage your clients.",
      confirmLabel: 'Sign Out',
    );
    if (confirmed) await controller.signOut();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete account?',
      message: 'This permanently deletes your coach profile, client relationships, chats and '
          'call history, and removes you as coach from your clients. '
          'This cannot be undone.',
      confirmLabel: 'Delete Account',
    );
    if (confirmed) await controller.deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = _textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Obx(() {
        final isDeleting = controller.isDeletingAccount.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isDeleting ? null : () => _confirmSignOut(context),
                icon: const Icon(Icons.logout, size: 20),
                label: Text('Sign Out', style: labelStyle),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: shape,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.smd),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isDeleting ? null : () => _confirmDelete(context),
                icon: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                      )
                    : const Icon(Icons.delete_outline, size: 20),
                label: Text(isDeleting ? 'Deleting account…' : 'Delete Account', style: labelStyle),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  disabledForegroundColor: AppColors.error.withValues(alpha: 0.6),
                  side: BorderSide(
                    color: isDeleting ? AppColors.error.withValues(alpha: 0.4) : AppColors.error,
                  ),
                  shape: shape,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
