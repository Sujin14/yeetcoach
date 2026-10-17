import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/message_status.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Coach messages sit on the right in the primary colour, client messages on the left.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const MessageBubble({super.key, required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final textColor = isMine ? AppColors.onPrimary : AppColors.onSurface;
    final metaColor = isMine ? AppColors.onPrimary.withValues(alpha: 0.75) : AppColors.subtle;
    const corner = Radius.circular(16);
    const tail = Radius.circular(4);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(AppSpacing.smd, AppSpacing.sm, AppSpacing.smd, 6),
          decoration: BoxDecoration(
            color: isMine ? AppColors.primary : AppColors.surface,
            border: isMine ? null : Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.only(
              topLeft: corner,
              topRight: corner,
              bottomLeft: isMine ? corner : tail,
              bottomRight: isMine ? tail : corner,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: Text(
                  message.text,
                  style: _textTheme.bodyMedium?.copyWith(fontSize: 15, color: textColor),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.sentAt),
                    style: _textTheme.bodySmall?.copyWith(fontSize: 11, color: metaColor),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      _statusIcon(message),
                      size: 14,
                      color: _isRead(message) ? AppColors.secondary : metaColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isRead(ChatMessage message) => !message.isPending && message.status == MessageStatus.read;

IconData _statusIcon(ChatMessage message) {
  if (message.isPending) return Icons.schedule;
  return switch (message.status) {
    MessageStatus.sent => Icons.check,
    MessageStatus.delivered || MessageStatus.read => Icons.done_all,
  };
}

/// "14:05" today, "Oct 3, 14:05" otherwise.
String _formatTime(DateTime sentAt) {
  final now = DateTime.now();
  final isToday = sentAt.year == now.year && sentAt.month == now.month && sentAt.day == now.day;
  return isToday ? DateFormat.Hm().format(sentAt) : DateFormat('MMM d, HH:mm').format(sentAt);
}
