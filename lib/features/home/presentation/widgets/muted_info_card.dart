import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Low-emphasis card for a section's empty state.
class MutedInfoCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const MutedInfoCard({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.subtle, size: 22),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Text(
                message,
                style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
