import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Small rounded label, e.g. "7 days" or "Active".
class ChallengeChip extends StatelessWidget {
  final String label;
  final Color color;

  const ChallengeChip({super.key, required this.label, this.color = AppColors.primary});

  const ChallengeChip.status({super.key, required bool isEnded})
      : label = isEnded ? 'Ended' : 'Active',
        color = isEnded ? AppColors.statusNone : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: _textTheme.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
