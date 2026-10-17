import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import '../../domain/entities/group_session.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class SessionCard extends StatelessWidget {
  final GroupSession session;
  final VoidCallback onDelete;

  const SessionCard({super.key, required this.session, required this.onDelete});

  Future<void> _join() async {
    final raw = session.meetLink.trim();
    final withScheme = raw.startsWith('http') ? raw : 'https://$raw';
    final uri = Uri.tryParse(withScheme);
    if (uri == null) {
      showErrorSnackbar('Could not open the Meet link.');
      return;
    }
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) showErrorSnackbar('Could not open the Meet link.');
    } catch (error) {
      logDebug('SessionCard: opening Meet link failed: $error');
      showErrorSnackbar('Could not open the Meet link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = session.isToday;
    final when = DateFormat('EEE, d MMM · h:mm a').format(session.scheduledAt);
    final description = session.description;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.smd, AppSpacing.xs, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.divider,
          width: isToday ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: _textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Delete session',
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: Text(
                  when,
                  style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Today',
                    style: _textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.onSurface),
            ),
          ],
          const SizedBox(height: AppSpacing.smd),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.smd),
            child: OutlinedButton.icon(
              onPressed: _join,
              icon: const Icon(Icons.video_call_outlined, size: 18),
              label: const Text('Join Meet'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
