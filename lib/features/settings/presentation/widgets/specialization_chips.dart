import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/features/auth/presentation/controllers/onboarding_controller.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Multi-select of the onboarding specializations, plus any custom ones already saved.
class SpecializationChips extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const SpecializationChips({super.key, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final options = {...OnboardingController.allSpecializations, ...selected}.toList();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (_) => onToggle(option),
            showCheckmark: false,
            labelStyle: _textTheme.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected.contains(option) ? AppColors.onPrimary : AppColors.onSurface,
            ),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: selected.contains(option) ? AppColors.primary : AppColors.divider,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
      ],
    );
  }
}
