import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/features/home/domain/entities/recovery_level.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class RecoveryLevelPill extends StatelessWidget {
  final RecoveryLevel? level;

  const RecoveryLevelPill({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final background = switch (level) {
      RecoveryLevel.excellent || RecoveryLevel.good => AppColors.statusGood,
      RecoveryLevel.fair => AppColors.statusFair,
      RecoveryLevel.needsRest => AppColors.statusPoor,
      null => AppColors.statusNone,
    };
    // White on amber is unreadable.
    final foreground = level == RecoveryLevel.fair ? AppColors.onSurface : AppColors.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(24)),
      child: Text(
        level != null ? 'Recovery: ${level!.label}' : 'No recovery data',
        style: _textTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
