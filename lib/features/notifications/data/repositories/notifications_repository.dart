import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/coach_notification_model.dart';
import '../../domain/entities/coach_notification.dart';

class NotificationsRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('coaches').doc(_uid).collection('notifications');

  /// Streams only unread notifications, newest first, up to 50.
  Stream<List<CoachNotification>> streamUnread() => _col
      .where('isRead', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs
          .map((d) => CoachNotificationModel.fromMap(d.id, d.data()))
          .toList());

  Future<void> markAllRead() async {
    final snap = await _col.where('isRead', isEqualTo: false).get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteAll() async {
    final snap = await _col.where('isRead', isEqualTo: false).get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
