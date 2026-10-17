import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/time_ago.dart';
import 'package:yeetcoach/core/widgets/confirmation_dialog.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/plan_list_controller.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Type-agnostic view of a workout or diet plan, so one card renders both.
typedef PlanSummary = ({
  String id,
  String title,
  String description,
  DateTime updatedAt,
  String countLabel,
  Object plan,
});

class PlanCard extends StatelessWidget {
  final PlanSummary summary;
  final PlanListController controller;

  const PlanCard({super.key, required this.summary, required this.controller});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete plan?',
      message: '${summary.title} will be permanently removed.',
    );
    if (confirmed) controller.deletePlan(summary.id);
  }

  @override
  Widget build(BuildContext context) {
    final subtleSmall = _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle);

    return Slidable(
      key: ValueKey(summary.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: _confirmDelete,
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onPrimary,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => controller.openEditForm(summary.plan),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(summary.countLabel, style: subtleSmall),
                  ],
                ),
                if (summary.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    summary.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _textTheme.bodySmall?.copyWith(fontSize: 13, color: AppColors.subtle),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 14, color: AppColors.subtle),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Updated ${timeAgo(summary.updatedAt)}', style: subtleSmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
