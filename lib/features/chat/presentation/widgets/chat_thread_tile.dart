import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/time_ago.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/chat_participant.dart';
import '../../domain/entities/chat_thread.dart';
import 'chat_avatar.dart';
import 'unread_badge.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class ChatThreadTile extends StatelessWidget {
  final ChatThread thread;

  /// Null while the client's profile is loading.
  final ChatParticipant? participant;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatThreadTile({
    super.key,
    required this.thread,
    required this.participant,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    final participant = this.participant;
    final lastActivityAt = thread.lastActivityAt;
    final preview = thread.lastMessage.trim();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      onTap: onTap,
      leading: participant == null
          ? const ShimmerBase(child: ShimmerCircle(size: 48))
          : ChatAvatar(name: participant.name, photoUrl: participant.photoUrl),
      title: participant == null
          ? const Align(
              alignment: Alignment.centerLeft,
              child: ShimmerBase(child: ShimmerBox(width: 140, height: 14, radius: 4)),
            )
          : Text(
              participant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
      subtitle: Text(
        preview.isEmpty ? 'No messages yet' : preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
          color: hasUnread ? AppColors.onSurface : AppColors.subtle,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lastActivityAt != null)
            Text(
              timeAgo(lastActivityAt),
              style: _textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: hasUnread ? AppColors.primary : AppColors.subtle,
              ),
            ),
          if (hasUnread) ...[
            const SizedBox(height: 6),
            UnreadBadge(count: unreadCount),
          ],
        ],
      ),
    );
  }
}
