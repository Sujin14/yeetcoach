import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/features/training/domain/entities/training_relationship.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// A request that was already accepted or declined; view only.
class RecentRequestTile extends StatelessWidget {
  final TrainingRelationship relationship;

  const RecentRequestTile({super.key, required this.relationship});

  @override
  Widget build(BuildContext context) {
    final name = relationship.clientName.isEmpty ? 'Client' : relationship.clientName;
    final accepted = relationship.status != RelationshipStatus.declined;
    final chipColor = accepted ? AppColors.success : AppColors.error;
    final decidedAt =
        relationship.updatedAt ?? relationship.acceptedAt ?? relationship.requestedAt;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shadowColor: const Color(0x0D000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.smd, 10, AppSpacing.smd, 10),
        child: Row(
          children: [
            PersonAvatar(name: name, photoUrl: relationship.clientPhoto, size: 40),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd().format(decidedAt),
                    style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                accepted ? 'Accepted' : 'Declined',
                style: _textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: chipColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
