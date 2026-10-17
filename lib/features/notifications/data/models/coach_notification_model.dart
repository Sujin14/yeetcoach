import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/coach_notification.dart';

class CoachNotificationModel extends CoachNotification {
  const CoachNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    super.clientUid,
    super.clientName,
    required super.isRead,
    required super.createdAt,
  });

  factory CoachNotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return CoachNotificationModel(
      id: id,
      type: _typeFromString(map['type'] as String? ?? 'message'),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      clientUid: map['clientUid'] as String?,
      clientName: map['clientName'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'title': title,
        'body': body,
        if (clientUid != null) 'clientUid': clientUid,
        if (clientName != null) 'clientName': clientName,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static NotificationType _typeFromString(String v) =>
      NotificationType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => NotificationType.message,
      );
}
