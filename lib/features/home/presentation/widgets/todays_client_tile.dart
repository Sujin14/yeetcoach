import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/features/clients/domain/entities/client_profile.dart';
import 'dashboard_view_button.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class TodaysClientTile extends StatelessWidget {
  final ClientProfile client;
  final VoidCallback onView;

  const TodaysClientTile({super.key, required this.client, required this.onView});

  @override
  Widget build(BuildContext context) {
    final name = client.name.trim().isEmpty ? 'Client' : client.name.trim();
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shadowColor: const Color(0x0D000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.smd, 10, AppSpacing.sm, 10),
        child: Row(
          children: [
            PersonAvatar(
              name: name,
              photoUrl: client.profileImageUrl ?? '',
              size: 40,
              fallbackBackground: AppColors.primary,
              fallbackForeground: Colors.white,
            ),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            DashboardViewButton(onPressed: onView),
          ],
        ),
      ),
    );
  }
}
