import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/widgets/staggered_entrance.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/coach_dashboard_controller.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class GreetingHeader extends GetView<CoachDashboardController> {
  const GreetingHeader({super.key});

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Obx(() {
        if (controller.isLoadingCoach.value || controller.isLoadingRelationships.value) {
          return const _GreetingHeaderShimmer();
        }
        final coach = controller.coach.value;
        final fullName = (coach?.name.isNotEmpty ?? false)
            ? coach!.name
            : (FirebaseAuth.instance.currentUser?.displayName ?? '');
        final firstName = fullName.trim().split(RegExp(r'\s+')).first;
        final clientCount = controller.activeRelationships.length;
        final rating = coach?.averageRating ?? 0;

        final card = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                Color.lerp(AppColors.primary, AppColors.onSurface, 0.55)!,
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${firstName.isEmpty ? 'Coach' : firstName} 👋',
                      style: _textTheme.headlineSmall?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      switch (clientCount) {
                        0 => 'No active clients yet',
                        1 => 'You have 1 active client',
                        _ => 'You have $clientCount active clients',
                      },
                      style: _textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: AppColors.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    if (rating > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.onPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '⭐ ${rating.toStringAsFixed(1)}',
                          style: _textTheme.labelLarge?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.smd),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.6), width: 2),
                ),
                child: PersonAvatar(
                  name: fullName,
                  photoUrl: coach?.profileImageUrl ?? '',
                  size: 48,
                  fallbackBackground: AppColors.onPrimary.withValues(alpha: 0.2),
                  fallbackForeground: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        );
        return StaggeredEntrance(index: 0, child: card);
      }),
    );
  }
}

class _GreetingHeaderShimmer extends StatelessWidget {
  const _GreetingHeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 220, height: 22, radius: 6),
                  SizedBox(height: 10),
                  ShimmerBox(width: 160, height: 14, radius: 6),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.smd),
            ShimmerCircle(size: 52),
          ],
        ),
      ),
    );
  }
}
