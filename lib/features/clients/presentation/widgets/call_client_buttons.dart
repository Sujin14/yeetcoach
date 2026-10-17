import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_type.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// "Audio Call", "Video Call" and "Message". The call buttons are disabled while a call is being set up.
class CallClientButtons extends StatelessWidget {
  final bool isStartingCall;
  final ValueChanged<CallType> onCall;
  final VoidCallback onMessage;

  const CallClientButtons({
    super.key,
    required this.isStartingCall,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Icon above the label so three buttons fit side by side on narrow phones.
    Widget button(IconData icon, String label, VoidCallback? onPressed) {
      return Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        button(
          Icons.call_outlined,
          'Audio Call',
          isStartingCall ? null : () => onCall(CallType.audio),
        ),
        const SizedBox(width: AppSpacing.smd),
        button(
          Icons.videocam_outlined,
          'Video Call',
          isStartingCall ? null : () => onCall(CallType.video),
        ),
        const SizedBox(width: AppSpacing.smd),
        button(Icons.chat_bubble_outline, 'Message', onMessage),
      ],
    );
  }
}
