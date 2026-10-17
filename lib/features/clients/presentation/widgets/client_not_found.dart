import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class ClientNotFoundState extends StatelessWidget {
  const ClientNotFoundState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 64, color: AppColors.subtle),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Client not found',
              style: _textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This client\'s profile may have been removed.',
              textAlign: TextAlign.center,
              style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}
