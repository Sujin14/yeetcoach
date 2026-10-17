import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/time_ago.dart';
import 'package:yeetcoach/features/training/domain/entities/training_relationship.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'initials_avatar.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class RequestCard extends StatelessWidget {
  final TrainingRelationship relationship;

  /// Disables both buttons while an accept or decline is in flight.
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RequestCard({
    super.key,
    required this.relationship,
    required this.isProcessing,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final name = relationship.clientName.isEmpty ? 'Client' : relationship.clientName;
    final photoUrl = relationship.clientPhoto;
    final fallbackAvatar = InitialsAvatar(name: name);
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    final labelStyle = _textTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shadowColor: const Color(0x0D000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.smd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (photoUrl.isEmpty)
                  fallbackAvatar
                else
                  CachedNetworkImage(
                    imageUrl: photoUrl,
                    imageBuilder: (_, image) => CircleAvatar(radius: 24, backgroundImage: image),
                    placeholder: (_, _) => fallbackAvatar,
                    errorWidget: (_, _, _) => fallbackAvatar,
                  ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                        'Requested ${timeAgo(relationship.requestedAt).toLowerCase()}',
                        style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
                      ),
                    ],
                  ),
                ),
                if (isProcessing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.smd),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: isProcessing ? AppColors.divider : AppColors.error,
                      ),
                      shape: buttonShape,
                    ),
                    child: Text('Decline', style: labelStyle),
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: FilledButton(
                    onPressed: isProcessing ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: buttonShape,
                    ),
                    child: Text('Accept', style: labelStyle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
