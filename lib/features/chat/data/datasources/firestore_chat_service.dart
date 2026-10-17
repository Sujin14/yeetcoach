import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_participant.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/entities/message_status.dart';
import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';

/// Reads and writes chats/{chatId} and its messages subcollection.
class FirestoreChatService {
  final FirebaseFirestore _firestore;

  FirestoreChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const int _messageLimit = 200;

  /// Firestore batches are capped at 500 writes.
  static const int _batchLimit = 500;

  static final List<String> _unreadStatuses = MessageStatus.values
      .where((status) => status.isUnread)
      .map((status) => status.name)
      .toList(growable: false);

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection(FirestoreCollections.chats);

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _chats.doc(chatId).collection(FirestoreCollections.chatMessages);

  Query<Map<String, dynamic>> _unreadFrom(String chatId, String senderUid) => _messages(chatId)
      .where('senderId', isEqualTo: senderUid)
      .where('status', whereIn: _unreadStatuses);

  /// Sorted on the device: ordering by updatedAt in the query would drop chats
  /// started from YeetFit, which never write that field.
  Stream<List<ChatThread>> watchCoachChats(String coachUid) {
    return _chats.where('participants', arrayContains: coachUid).snapshots().map((snapshot) {
      final threads = snapshot.docs
          .map((doc) => ChatThreadModel.fromSnapshot(doc, coachUid: coachUid))
          .where((thread) => thread.clientUid.isNotEmpty)
          .toList();
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      threads.sort((a, b) => (b.lastActivityAt ?? epoch).compareTo(a.lastActivityAt ?? epoch));
      return threads;
    });
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _messages(chatId)
        .orderBy('timestamp', descending: true)
        .limit(_messageLimit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ChatMessageModel.fromSnapshot).toList());
  }

  Stream<int> watchUnreadCount(String chatId, String senderUid) {
    return _unreadFrom(chatId, senderUid).snapshots().map((snapshot) => snapshot.size);
  }

  Future<ChatParticipant?> getParticipant(String uid) async {
    final doc = await _firestore.collection(FirestoreCollections.users).doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    final name = (data['name'] as String?)?.trim();
    return ChatParticipant(
      uid: uid,
      name: name == null || name.isEmpty ? 'Client' : name,
      photoUrl: data['profileImageUrl'] as String? ?? data['profilePicture'] as String? ?? '',
    );
  }

  Future<void> sendMessage({
    required String coachUid,
    required ChatParticipant client,
    required String text,
  }) async {
    final chatRef = _chats.doc(ChatThread.idFor(coachUid, client.uid));
    // Created on its own first: the message rule reads the parent chat, and a
    // batch's rule checks see the database as it was before the batch.
    if (!(await chatRef.get()).exists) {
      await chatRef.set(ChatThreadModel.toCreateMap(
        coachUid: coachUid,
        clientUid: client.uid,
        clientName: client.name,
      ));
    }
    final batch = _firestore.batch()
      ..set(
        chatRef.collection(FirestoreCollections.chatMessages).doc(),
        ChatMessageModel.toCreateMap(
          senderId: coachUid,
          participants: [coachUid, client.uid],
          participantName: client.name,
          text: text,
        ),
      )
      // YeetFit refreshes an open chat's messages only when this document changes.
      ..update(chatRef, ChatThreadModel.toNewMessageMap(text));
    await batch.commit();
  }

  /// Removes every message, then the chat document, matching YeetFit's delete.
  Future<void> deleteChat(String chatId) async {
    final messages = _messages(chatId);
    while (true) {
      final snapshot = await messages.limit(_batchLimit).get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snapshot.docs.length < _batchLimit) break;
    }
    await _chats.doc(chatId).delete();
  }

  Future<void> markAsRead(String chatId, String senderUid) async {
    final snapshot = await _unreadFrom(chatId, senderUid).get();
    final docs = snapshot.docs;
    for (var start = 0; start < docs.length; start += _batchLimit) {
      final batch = _firestore.batch();
      for (final doc in docs.skip(start).take(_batchLimit)) {
        batch.update(doc.reference, {'status': MessageStatus.read.name});
      }
      await batch.commit();
    }
  }
}
