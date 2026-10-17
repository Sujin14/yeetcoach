import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class PlanEmptyState extends StatelessWidget {
  final bool isWorkout;

  const PlanEmptyState({super.key, required this.isWorkout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.background,
                BlendMode.multiply,
              ),
              child: Image.asset(
                'assets/images/empty_plans.webp',
                height: 180,
                cacheHeight: (180 * MediaQuery.devicePixelRatioOf(context)).round(),
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isWorkout ? 'No workout plans yet' : 'No diet plans yet',
              textAlign: TextAlign.center,
              style: _textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the button below to create the first plan for this client.',
              textAlign: TextAlign.center,
              style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}
