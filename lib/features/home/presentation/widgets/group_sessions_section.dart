import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/confirmation_dialog.dart';
import 'package:yeetcoach/core/widgets/section_header.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/widgets/staggered_entrance.dart';
import 'package:yeetcoach/features/sessions/domain/entities/group_session.dart';
import 'package:yeetcoach/features/sessions/presentation/controllers/session_controller.dart';
import 'package:yeetcoach/features/sessions/presentation/widgets/create_session_sheet.dart';
import 'package:yeetcoach/features/sessions/presentation/widgets/session_card.dart';
import 'list_tile_card_shimmer.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
);

class GroupSessionsSection extends GetView<SessionController> {
  const GroupSessionsSection({super.key});

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: AppColors.surface,
      shape: _sheetShape,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      builder: (_) => const CreateSessionSheet(),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GroupSession session) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete session?',
      message: 'Remove "${session.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed) await controller.deleteSession(session.id);
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredEntrance(
      index: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
            child: SectionHeader(
              title: 'Group Sessions',
              trailing: TextButton(
                onPressed: () => _openCreateSheet(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  'Schedule',
                  style: _textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: ShimmerBase(child: ListTileCardShimmer()),
              );
            }
            final upcoming = controller.sessions;
            if (upcoming.isEmpty) {
              return _EmptySessionsCard(onTap: () => _openCreateSheet(context));
            }
            return Column(
              children: [
                for (final session in upcoming)
                  SessionCard(
                    key: ValueKey(session.id),
                    session: session,
                    onDelete: () => _confirmDelete(context, session),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _EmptySessionsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptySessionsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.video_call_outlined, color: AppColors.subtle, size: 22),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Text(
                    'Tap to schedule a group session',
                    style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
