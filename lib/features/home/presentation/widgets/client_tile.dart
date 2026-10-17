import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/features/clients/domain/entities/client_profile.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'initials_avatar.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class ClientTile extends StatelessWidget {
  final ClientProfile client;

  const ClientTile({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final imageUrl = client.profileImageUrl;
    final fallback = InitialsAvatar(
      name: client.name,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      leading: (imageUrl == null || imageUrl.isEmpty)
          ? fallback
          : CachedNetworkImage(
              imageUrl: imageUrl,
              imageBuilder: (_, image) => CircleAvatar(radius: 24, backgroundImage: image),
              placeholder: (_, _) => fallback,
              errorWidget: (_, _, _) => fallback,
            ),
      title: Text(
        client.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _textTheme.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        _clientSubtitle(client),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtle),
      onTap: () => Get.toNamed(AppRoutes.clientDetails, arguments: {'uid': client.uid}),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

/// YeetFit stores these exact strings on users/{uid}.goal.
String _goalLabel(String goal) {
  return switch (goal.toLowerCase()) {
    'weight loss' => 'Lose weight',
    'weight gain' => 'Gain weight',
    'muscle building' => 'Build muscle',
    _ => goal,
  };
}

String _clientSubtitle(ClientProfile client) {
  final level = client.fitnessLevel == null ? null : _capitalize(client.fitnessLevel!.name);
  final rawGoal = client.primaryGoal?.trim();
  final goal = rawGoal == null || rawGoal.isEmpty ? null : _goalLabel(rawGoal);

  if (level != null && goal != null) return '$level · $goal';
  if (level != null) return level;
  if (goal != null) return goal;
  return 'No goals set';
}
