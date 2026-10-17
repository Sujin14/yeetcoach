import 'package:flutter/material.dart';
import '../../domain/entities/coach_notification.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final CoachNotification notif;

  /// When this animation runs forward the card fades out and slides right.
  final Animation<double> animation;

  const NotificationCard({
    super.key,
    required this.notif,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1.3, 0),
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInCubic),
          ),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: _accentColor().withValues(alpha: 0.12),
            child: Icon(_icon(), color: _accentColor(), size: 20),
          ),
          title: Text(
            notif.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.body,
                    style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 4),
                Text(
                  _formatTime(notif.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }

  IconData _icon() {
    switch (notif.type) {
      case NotificationType.request:
        return Icons.person_add_outlined;
      case NotificationType.missedCall:
        return Icons.call_missed_outgoing;
      case NotificationType.progress:
        return Icons.trending_up;
      case NotificationType.message:
        return Icons.chat_bubble_outline;
      case NotificationType.session:
        return Icons.video_call_outlined;
    }
  }

  Color _accentColor() {
    switch (notif.type) {
      case NotificationType.request:
        return AppColors.primary;
      case NotificationType.missedCall:
        return Colors.red;
      case NotificationType.progress:
        return Colors.green;
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.session:
        return Colors.purple;
    }
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
