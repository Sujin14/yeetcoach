import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/time_ago.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/recovery_level.dart';
import 'recovery_badge.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class ClientActivityCard extends StatelessWidget {
  static const width = 132.0;

  final String name;
  final String photoUrl;
  final RecoveryLevel? recoveryLevel;
  final DateTime lastActive;
  final VoidCallback onTap;

  const ClientActivityCard({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.recoveryLevel,
    required this.lastActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? 'Client' : name;
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        shadowColor: const Color(0x0D000000),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, AppSpacing.smd),
            child: Column(
              children: [
                PersonAvatar(name: displayName, photoUrl: photoUrl, size: 56),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                RecoveryBadge(level: recoveryLevel),
                const SizedBox(height: 6),
                Text(
                  timeAgo(lastActive),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.subtle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
