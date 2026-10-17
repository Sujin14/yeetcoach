import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/recovery_level.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Recovery pill; shows "—" when the client hasn't shared a recovery score.
class RecoveryBadge extends StatelessWidget {
  final RecoveryLevel? level;

  const RecoveryBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      RecoveryLevel.excellent || RecoveryLevel.good => AppColors.success,
      RecoveryLevel.fair => AppColors.secondary,
      RecoveryLevel.needsRest => AppColors.error,
      null => AppColors.subtle,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        level != null ? 'Recovery: ${level!.label}' : '—',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
