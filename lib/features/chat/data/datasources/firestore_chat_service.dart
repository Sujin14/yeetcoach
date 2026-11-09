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

  /// Soft-delete batches stay under Firestore's 500-write cap.
  static const int _deleteBatchLimit = 450;

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
  /// Chats cleared for the coach stay hidden until a newer lastMessageTime arrives.
  Stream<List<ChatThread>> watchCoachChats(String coachUid) {
    return _chats.where('participants', arrayContains: coachUid).snapshots().map((snapshot) {
      final threads = snapshot.docs
          .map((doc) => ChatThreadModel.fromSnapshot(doc, coachUid: coachUid))
          .where((thread) => thread.clientUid.isNotEmpty && !thread.isClearedForViewer)
          .toList();
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      threads.sort((a, b) => (b.lastActivityAt ?? epoch).compareTo(a.lastActivityAt ?? epoch));
      return threads;
    });
  }

  /// [clearedAt] limits to messages after the coach cleared the chat; [uid]'s
  /// soft-deleted messages are dropped client-side.
  Stream<List<ChatMessage>> watchMessages(String chatId, String uid, {DateTime? clearedAt}) {
    Query<Map<String, dynamic>> query = _messages(chatId);
    if (clearedAt != null) {
      query = query.where('timestamp', isGreaterThan: Timestamp.fromDate(clearedAt));
    }
    return query
        .orderBy('timestamp', descending: true)
        .limit(_messageLimit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ChatMessageModel.fromSnapshot)
              .where((message) => !message.deletedFor.contains(uid))
              .toList(),
        );
  }

  /// Live [clearedAt] for [uid] on the chat doc; emits null when unset or missing.
  Stream<DateTime?> watchClearedAt(String chatId, String uid) {
    return _chats.doc(chatId).snapshots().map((snapshot) {
      final clearedAt = snapshot.data()?['clearedAt'];
      if (clearedAt is! Map) return null;
      return (clearedAt[uid] as Timestamp?)?.toDate();
    });
  }

  /// Unread from [senderUid], excluding soft-deleted / cleared messages for [viewerUid].
  Stream<int> watchUnreadCount(String chatId, String senderUid, String viewerUid) {
    return _chats.doc(chatId).snapshots().asyncExpand((chatSnap) {
      final clearedAtRaw = chatSnap.data()?['clearedAt'];
      DateTime? clearedAt;
      if (clearedAtRaw is Map) {
        clearedAt = (clearedAtRaw[viewerUid] as Timestamp?)?.toDate();
      }
      return _unreadFrom(chatId, senderUid).snapshots().map((snapshot) {
        return snapshot.docs.where((doc) {
          final data = doc.data();
          final deletedFor =
              (data['deletedFor'] as List?)?.whereType<String>() ?? const Iterable<String>.empty();
          if (deletedFor.contains(viewerUid)) return false;
          if (clearedAt == null) return true;
          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
          if (timestamp == null) return true;
          return timestamp.isAfter(clearedAt);
        }).length;
      });
    });
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

  /// Soft-deletes [messageIds] for [uid] only (chunks of [_deleteBatchLimit]).
  Future<void> deleteMessagesForMe(String chatId, List<String> messageIds, String uid) async {
    final messages = _messages(chatId);
    for (var start = 0; start < messageIds.length; start += _deleteBatchLimit) {
      final batch = _firestore.batch();
      for (final id in messageIds.skip(start).take(_deleteBatchLimit)) {
        batch.update(messages.doc(id), {
          'deletedFor': FieldValue.arrayUnion([uid]),
        });
      }
      await batch.commit();
    }
  }

  /// Hides the chat for [uid] without removing messages or the chat document.
  Future<void> clearChatForMe(String chatId, String uid) async {
    await _chats.doc(chatId).set(
      {
        'clearedAt': {uid: FieldValue.serverTimestamp()},
      },
      SetOptions(merge: true),
    );
  }

  Future<void> markAsRead(String chatId, String senderUid) async {
    final snapshot = await _unreadFrom(chatId, senderUid).get();
    final docs = snapshot.docs;
    for (var start = 0; start < docs.length; start += _deleteBatchLimit) {
      final batch = _firestore.batch();
      for (final doc in docs.skip(start).take(_deleteBatchLimit)) {
        batch.update(doc.reference, {'status': MessageStatus.read.name});
      }
      await batch.commit();
    }
  }
}
