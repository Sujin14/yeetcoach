import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class PlanButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  const PlanButton({
    super.key,
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = _textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    const padding = EdgeInsets.symmetric(vertical: 14);

    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton.icon(
              icon: Icon(icon),
              label: Text(label, style: labelStyle),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: padding,
                shape: shape,
                elevation: 0,
              ),
              onPressed: onPressed,
            )
          : OutlinedButton.icon(
              icon: Icon(icon),
              label: Text(label, style: labelStyle),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: padding,
                shape: shape,
              ),
              onPressed: onPressed,
            ),
    );
  }
}
