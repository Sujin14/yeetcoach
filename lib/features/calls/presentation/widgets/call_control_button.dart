import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Round call control with a caption. [isActive] highlights a toggled-on state (e.g. muted).
/// A null [onPressed] dims the button; [isBusy] swaps the icon for a spinner.
class CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isBusy;
  final Color? backgroundColor;
  final double size;

  const CallControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
    this.isBusy = false,
    this.backgroundColor,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ??
        (isActive ? AppColors.onPrimary : AppColors.onPrimary.withValues(alpha: 0.18));
    final foreground =
        backgroundColor == null && isActive ? AppColors.primary : AppColors.onPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: onPressed == null && !isBusy ? 0.5 : 1,
          child: Material(
            color: background,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: size,
                height: size,
                child: isBusy
                    ? Center(
                        child: SizedBox(
                          width: size * 0.36,
                          height: size * 0.36,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: foreground),
                        ),
                      )
                    : Icon(icon, color: foreground, size: size * 0.42),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.onPrimary),
        ),
      ],
    );
  }
}
