import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/features/home/presentation/widgets/muted_info_card.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/challenge.dart';
import '../controllers/challenge_detail_controller.dart';
import '../widgets/challenge_chip.dart';
import '../widgets/challenge_format.dart';
import '../widgets/challenge_progress.dart';
import '../widgets/end_challenge_dialog.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class ChallengeDetailScreen extends GetView<ChallengeDetailController> {
  const ChallengeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          // Navigator rather than Get.back, which closes an open snackbar instead of the route.
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Challenge Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const _DetailShimmer();
        final challenge = controller.challenge.value;
        if (challenge == null) {
          return const Padding(
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: MutedInfoCard(
              icon: Icons.search_off,
              message: 'This challenge no longer exists.',
            ),
          );
        }
        final now = controller.now.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
          children: [
            _HeaderCard(challenge: challenge, now: now),
            const SizedBox(height: AppSpacing.md),
            _InfoCard(challenge: challenge),
            const SizedBox(height: AppSpacing.md),
            _DetailCard(
              title: 'Timeline',
              child: ChallengeProgress(challenge: challenge, now: now),
            ),
            const SizedBox(height: AppSpacing.md),
            const _AssignedClientsCard(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final challenge = controller.challenge.value;
        if (challenge == null || challenge.isEndedAt(controller.now.value)) {
          return const SizedBox.shrink();
        }
        return _EndChallengeBar(challenge: challenge);
      }),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const _DetailCard({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: _textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.smd),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Challenge challenge;
  final DateTime now;

  const _HeaderCard({required this.challenge, required this.now});

  @override
  Widget build(BuildContext context) {
    final isEnded = challenge.isEndedAt(now);
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isEnded ? AppColors.statusNone : AppColors.secondary).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: isEnded ? AppColors.statusNone : AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Text(
                  challenge.title,
                  style: _textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ChallengeChip.status(isEnded: isEnded),
            ],
          ),
          if (challenge.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.smd),
            Text(
              challenge.description,
              style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Challenge challenge;

  const _InfoCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Details',
      child: Column(
        children: [
          _InfoRow(
            icon: challengeTypeIcon(challenge.type),
            label: 'Type',
            value: challenge.type.label,
          ),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Target',
            value: formatChallengeTarget(challenge.type, challenge.targetValue),
          ),
          _InfoRow(
            icon: Icons.timelapse,
            label: 'Duration',
            value: '${challenge.durationDays} days',
          ),
          _InfoRow(
            icon: Icons.play_circle_outline,
            label: 'Starts',
            value: formatChallengeDate(challenge.startDate),
          ),
          _InfoRow(
            icon: Icons.stop_circle_outlined,
            label: 'Ends',
            value: formatChallengeDate(challenge.endDate),
          ),
          _InfoRow(
            icon: Icons.groups_outlined,
            label: 'Joined in YeetFit',
            value: NumberFormat.decimalPattern().format(challenge.participantCount),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label, style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle)),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: _textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedClientsCard extends GetView<ChallengeDetailController> {
  const _AssignedClientsCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final assignedCount = controller.challenge.value?.assignedTo.length ?? 0;
      final Widget body;
      if (assignedCount == 0) {
        body = Text(
          'Not assigned to specific clients. Every YeetFit user can join.',
          style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
        );
      } else if (controller.isLoadingMembers.value) {
        body = ShimmerBase(
          child: Column(
            children: [
              for (var i = 0; i < assignedCount.clamp(1, 4); i++)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      ShimmerCircle(size: 40),
                      SizedBox(width: AppSpacing.smd),
                      ShimmerBox(width: 140, height: 14, radius: 6),
                    ],
                  ),
                ),
            ],
          ),
        );
      } else {
        body = Column(
          children: [
            for (final member in controller.members)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    PersonAvatar(name: member.name, photoUrl: member.photoUrl, size: 40),
                    const SizedBox(width: AppSpacing.smd),
                    Expanded(
                      child: Text(
                        member.name,
                        overflow: TextOverflow.ellipsis,
                        style: _textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }
      return _DetailCard(
        title: assignedCount == 0 ? 'Assigned clients' : 'Assigned clients ($assignedCount)',
        child: body,
      );
    });
  }
}

class _EndChallengeBar extends GetView<ChallengeDetailController> {
  final Challenge challenge;

  const _EndChallengeBar({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.smd, AppSpacing.md, AppSpacing.smd),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: Obx(() {
            final isEnding = controller.isEnding.value;
            return OutlinedButton.icon(
              onPressed: isEnding
                  ? null
                  : () async {
                      if (await confirmEndChallenge(context, challenge)) {
                        await controller.endChallenge();
                      }
                    },
              icon: isEnding
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                    )
                  : const Icon(Icons.stop_circle_outlined, size: 20),
              label: Text(
                isEnding ? 'Ending…' : 'End Challenge',
                style: _textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                disabledForegroundColor: AppColors.error.withValues(alpha: 0.6),
                side: BorderSide(color: AppColors.error.withValues(alpha: isEnding ? 0.4 : 1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Mirrors the header, details and timeline cards.
class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    Widget card(List<Widget> children) => Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ShimmerBase(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        card(const [
          Row(
            children: [
              ShimmerCircle(size: 44),
              SizedBox(width: AppSpacing.smd),
              ShimmerBox(width: 180, height: 20, radius: 6),
            ],
          ),
          SizedBox(height: AppSpacing.smd),
          ShimmerBox(width: double.infinity, height: 14, radius: 6),
        ]),
        card([
          const ShimmerBox(width: 80, height: 16, radius: 6),
          const SizedBox(height: AppSpacing.smd),
          for (var i = 0; i < 6; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  ShimmerBox(width: 90, height: 14, radius: 6),
                  Spacer(),
                  ShimmerBox(width: 100, height: 14, radius: 6),
                ],
              ),
            ),
        ]),
        card(const [
          ShimmerBox(width: 80, height: 16, radius: 6),
          SizedBox(height: AppSpacing.smd),
          ShimmerBox(width: double.infinity, height: 6, radius: 4),
        ]),
      ],
    );
  }
}
