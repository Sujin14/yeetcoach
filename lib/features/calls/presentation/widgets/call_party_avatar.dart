import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import '../../domain/entities/call_party.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// The client's photo on the call screen, falling back to initials.
class CallPartyAvatar extends StatelessWidget {
  final CallParty party;
  final double radius;

  const CallPartyAvatar({super.key, required this.party, this.radius = 56});

  String get _initials {
    final parts = party.name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.onPrimary.withValues(alpha: 0.18),
      child: Text(
        _initials,
        style: _textTheme.titleLarge?.copyWith(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );

    if (party.photoUrl.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: party.photoUrl,
      imageBuilder: (_, image) => CircleAvatar(radius: radius, backgroundImage: image),
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
