import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Network photo with an initials fallback while loading, on error, or when no URL is set.
class CoachAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;

  const CoachAvatar({super.key, required this.url, required this.name, this.radius = 44});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        _initials,
        style: _textTheme.bodyLarge?.copyWith(
          fontSize: radius / 2,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );

    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) return fallback;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (_, image) => CircleAvatar(radius: radius, backgroundImage: image),
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
