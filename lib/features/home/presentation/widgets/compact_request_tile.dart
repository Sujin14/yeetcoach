import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/time_ago.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/features/training/domain/entities/training_relationship.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'dashboard_view_button.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class CompactRequestTile extends StatelessWidget {
  final TrainingRelationship request;
  final VoidCallback onView;

  const CompactRequestTile({super.key, required this.request, required this.onView});

  @override
  Widget build(BuildContext context) {
    final name = request.clientName.isEmpty ? 'Client' : request.clientName;
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
            PersonAvatar(name: name, photoUrl: request.clientPhoto, size: 40),
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
                  Text(
                    'Requested ${timeAgo(request.requestedAt)}',
                    style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
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
