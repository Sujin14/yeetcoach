import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/challenge.dart';
import 'assigned_avatars_row.dart';
import 'challenge_chip.dart';
import 'challenge_format.dart';
import 'challenge_progress.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Ended challenges render greyed out without action buttons.
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final DateTime now;
  final Map<String, ChallengeMember> members;
  final bool showStatusChip;
  final bool isEnding;
  final VoidCallback onViewDetails;
  final VoidCallback onEnd;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.now,
    required this.members,
    required this.onViewDetails,
    required this.onEnd,
    this.showStatusChip = false,
    this.isEnding = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnded = challenge.isEndedAt(now);
    final accent = isEnded ? AppColors.statusNone : AppColors.primary;

    final card = Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.cardShadow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.emoji_events, size: 22, color: isEnded ? AppColors.statusNone : AppColors.secondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      challenge.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  if (showStatusChip) ...[
                    const SizedBox(width: AppSpacing.sm),
                    ChallengeChip.status(isEnded: isEnded),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(challengeTypeIcon(challenge.type), size: 18, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formatChallengeTarget(challenge.type, challenge.targetValue),
                      style: _textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  ChallengeChip(label: '${challenge.durationDays} days', color: accent),
                ],
              ),
              const SizedBox(height: 14),
              ChallengeProgress(challenge: challenge, now: now),
              const SizedBox(height: AppSpacing.smd),
              AssignedAvatarsRow(uids: challenge.assignedTo, members: members),
              if (!isEnded) ...[
                const SizedBox(height: 14),
                _CardActions(isEnding: isEnding, onViewDetails: onViewDetails, onEnd: onEnd),
              ],
            ],
          ),
        ),
      ),
    );

    return isEnded ? Opacity(opacity: 0.65, child: card) : card;
  }
}

class _CardActions extends StatelessWidget {
  final bool isEnding;
  final VoidCallback onViewDetails;
  final VoidCallback onEnd;

  const _CardActions({required this.isEnding, required this.onViewDetails, required this.onEnd});

  @override
  Widget build(BuildContext context) {
    final labelStyle = _textTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onViewDetails,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: shape,
            ),
            child: Text('View Details', style: labelStyle),
          ),
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: OutlinedButton(
            onPressed: isEnding ? null : onEnd,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: isEnding ? 0.4 : 1)),
              shape: shape,
            ),
            child: isEnding
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                  )
                : Text('End Challenge', style: labelStyle),
          ),
        ),
      ],
    );
  }
}
