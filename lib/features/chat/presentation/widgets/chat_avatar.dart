import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Client photo, falling back to their initials while loading or when there is none.
class ChatAvatar extends StatelessWidget {
  final String name;
  final String photoUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ChatAvatar({
    super.key,
    required this.name,
    this.photoUrl = '',
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        _initials(name),
        style: _textTheme.titleMedium?.copyWith(
          fontSize: radius * 0.66,
          fontWeight: FontWeight.w700,
          color: foregroundColor ?? AppColors.primary,
        ),
      ),
    );
    if (photoUrl.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: photoUrl,
      imageBuilder: (_, image) => CircleAvatar(radius: radius, backgroundImage: image),
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  if (parts.isEmpty) return '?';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
