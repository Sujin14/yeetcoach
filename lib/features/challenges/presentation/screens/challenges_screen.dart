import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/features/home/presentation/widgets/muted_info_card.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/challenge.dart';
import '../controllers/challenges_controller.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_card_shimmer.dart';
import '../widgets/create_challenge_sheet.dart';
import '../widgets/end_challenge_dialog.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

enum _ChallengeTab { active, ended, all }

/// Challenges tab of /home: Active / Ended / All lists and the New Challenge FAB.
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _ChallengeTab.values.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: const Text(
            'Challenges',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            labelColor: AppColors.onPrimary,
            unselectedLabelColor: AppColors.onPrimary.withValues(alpha: 0.7),
            indicatorColor: AppColors.onPrimary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.onPrimary.withValues(alpha: 0.24),
            labelStyle: _textTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                _textTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            tabs: const [Tab(text: 'Active'), Tab(text: 'Ended'), Tab(text: 'All')],
          ),
        ),
        body: const TabBarView(
          children: [
            _ChallengeList(tab: _ChallengeTab.active),
            _ChallengeList(tab: _ChallengeTab.ended),
            _ChallengeList(tab: _ChallengeTab.all),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            heroTag: 'new-challenge',
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            onPressed: () async {
              final tabs = DefaultTabController.of(context);
              if (await CreateChallengeSheet.show()) tabs.animateTo(_ChallengeTab.active.index);
            },
            icon: const Icon(Icons.add),
            label: Text(
              'New Challenge',
              style: _textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengeList extends GetView<ChallengesController> {
  final _ChallengeTab tab;

  const _ChallengeList({required this.tab});

  String get _emptyMessage => switch (tab) {
        _ChallengeTab.active => 'No active challenges. Create one below! 💪',
        _ChallengeTab.ended => 'No ended challenges yet',
        _ChallengeTab.all => 'No challenges yet. Create one below! 💪',
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.smd),
          itemBuilder: (_, _) => const ChallengeCardShimmer(),
        );
      }
      if (controller.hasError.value) {
        return const _ListMessage(
          icon: Icons.cloud_off_outlined,
          message: "Couldn't load challenges. Check your connection and try again.",
        );
      }

      // Read every Rx here: lazily built items don't register with Obx.
      final now = controller.now.value;
      final members = Map<String, ChallengeMember>.of(controller.members);
      final endingIds = controller.endingIds.toSet();
      final challenges = switch (tab) {
        _ChallengeTab.active => controller.activeChallenges,
        _ChallengeTab.ended => controller.endedChallenges,
        _ChallengeTab.all => controller.challenges.toList(),
      };
      if (challenges.isEmpty) {
        return _EmptyChallenges(message: _emptyMessage);
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
        itemCount: challenges.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.smd),
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return ChallengeCard(
            key: ValueKey(challenge.id),
            challenge: challenge,
            now: now,
            members: members,
            showStatusChip: tab == _ChallengeTab.all,
            isEnding: endingIds.contains(challenge.id),
            onViewDetails: () => Get.toNamed(
              AppRoutes.challengeDetails,
              arguments: {'id': challenge.id, 'challenge': challenge},
            ),
            onEnd: () async {
              if (await confirmEndChallenge(context, challenge)) {
                await controller.endChallenge(challenge);
              }
            },
          );
        },
      );
    });
  }
}

class _EmptyChallenges extends StatelessWidget {
  final String message;

  const _EmptyChallenges({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events, size: 32, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Text(
                    message,
                    style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ListMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _ListMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 96),
      children: [MutedInfoCard(icon: icon, message: message)],
    );
  }
}
