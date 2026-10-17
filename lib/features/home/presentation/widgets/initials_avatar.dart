import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class InitialsAvatar extends StatelessWidget {
  final String name;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: backgroundColor ?? AppColors.primary.withValues(alpha: 0.12),
      foregroundColor: foregroundColor ?? AppColors.primary,
      child: Text(
        _initials(name),
        style: _textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: foregroundColor ?? AppColors.primary,
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  if (parts.isEmpty) return '?';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
