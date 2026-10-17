import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import '../../domain/entities/challenge.dart';
import 'challenge_format.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Days-elapsed bar with "Day X of N" and the days-left label (red when 2 or fewer remain).
class ChallengeProgress extends StatelessWidget {
  final Challenge challenge;
  final DateTime now;

  const ChallengeProgress({super.key, required this.challenge, required this.now});

  @override
  Widget build(BuildContext context) {
    final isEnded = challenge.isEndedAt(now);
    final progress = challenge.progressAt(now);
    final timing = challengeTimingLabel(challenge, now);
    final elapsedDays = (progress * challenge.durationDays).ceil().clamp(0, challenge.durationDays);
    final smallStyle = _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation(isEnded ? AppColors.statusNone : AppColors.primary),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Day $elapsedDays of ${challenge.durationDays}', style: smallStyle),
            const Spacer(),
            Text(
              timing.text,
              style: smallStyle?.copyWith(
                fontWeight: FontWeight.w600,
                color: timing.urgent ? AppColors.error : AppColors.subtle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
