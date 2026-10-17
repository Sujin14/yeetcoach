import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class EmptyClientsView extends StatelessWidget {
  const EmptyClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.background,
                BlendMode.multiply,
              ),
              child: Image.asset(
                'assets/images/empty_clients.webp',
                height: 180,
                cacheHeight: (180 * MediaQuery.devicePixelRatioOf(context)).round(),
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No clients yet',
              style: _textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'When a client sends you a training request and you accept it, they\'ll appear here.',
              textAlign: TextAlign.center,
              style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}
