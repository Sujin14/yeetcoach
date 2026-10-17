import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/call_party.dart';
import 'call_control_button.dart';
import 'call_party_avatar.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// The ringing state of a call from a client: caller details with Decline and Answer.
class IncomingCallView extends StatelessWidget {
  final CallParty caller;
  final bool isVideo;

  /// Disables both buttons and shows a spinner on Answer.
  final bool isAnswering;
  final VoidCallback onAnswer;
  final VoidCallback onDecline;

  const IncomingCallView({
    super.key,
    required this.caller,
    required this.isVideo,
    required this.isAnswering,
    required this.onAnswer,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 72),
          CallPartyAvatar(party: caller),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              caller.name,
              textAlign: TextAlign.center,
              style: _textTheme.titleLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isVideo ? 'Video call' : 'Audio call',
            style: _textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              color: AppColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CallControlButton(
                  icon: Icons.call_end,
                  label: 'Decline',
                  size: 72,
                  backgroundColor: AppColors.error,
                  onPressed: isAnswering ? null : onDecline,
                ),
                CallControlButton(
                  icon: isVideo ? Icons.videocam : Icons.call,
                  label: 'Answer',
                  size: 72,
                  backgroundColor: AppColors.success,
                  isBusy: isAnswering,
                  onPressed: isAnswering ? null : onAnswer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
