import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/time_ago.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/features/clients/domain/entities/client_profile.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/client_detail_controller.dart';
import 'recovery_level_pill.dart';
import 'recovery_ring.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class ClientHeroCard extends GetView<ClientDetailController> {
  final ClientProfile client;

  const ClientHeroCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recoveryLoading = controller.isSectionLoading(ClientDetailSection.recovery);
      final relationshipLoading = controller.isSectionLoading(ClientDetailSection.relationship);
      final recovery = controller.recovery.value;
      final trainingSince = controller.relationship.value?.trainingSince;
      final updatedAt = recovery.updatedAt;
      final mutedOnPrimary = AppColors.onPrimary.withValues(alpha: 0.8);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color.lerp(AppColors.primary, AppColors.onSurface, 0.55)!,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.6), width: 2),
                  ),
                  child: PersonAvatar(
                    name: client.name,
                    photoUrl: client.profileImageUrl ?? '',
                    size: 80,
                    fallbackBackground: AppColors.onPrimary.withValues(alpha: 0.2),
                    fallbackForeground: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name.isEmpty ? 'Client' : client.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      if (!relationshipLoading && trainingSince != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Training since ${DateFormat.yMMMd().format(trainingSince)}',
                          style: _textTheme.bodySmall?.copyWith(fontSize: 13, color: mutedOnPrimary),
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (recoveryLoading)
                        const ShimmerBase(child: ShimmerBox(width: 84, height: 22, radius: 24))
                      else
                        RecoveryLevelPill(level: recovery.level),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (recoveryLoading)
              const ShimmerBase(child: ShimmerCircle(size: 120))
            else ...[
              RecoveryRing(score: recovery.score),
              const SizedBox(height: AppSpacing.sm),
              Text(
                switch ((updatedAt, recovery.hasScore)) {
                  (final DateTime at, _) => 'Updated ${timeAgo(at).toLowerCase()}',
                  (null, true) => 'Updated just now',
                  (null, false) => 'No recovery score yet',
                },
                style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: mutedOnPrimary),
              ),
            ],
          ],
        ),
      );
    });
  }
}
