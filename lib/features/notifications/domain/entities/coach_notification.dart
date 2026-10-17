import 'package:flutter/foundation.dart';

enum NotificationType { request, missedCall, progress, message, session }

@immutable
class CoachNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? clientUid;
  final String? clientName;
  final bool isRead;
  final DateTime createdAt;

  const CoachNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.clientUid,
    this.clientName,
    required this.isRead,
    required this.createdAt,
  });
}
