import 'package:flutter/foundation.dart';

/// Display details for the client on the other side of a chat.
@immutable
class ChatParticipant {
  final String uid;
  final String name;
  final String photoUrl;

  const ChatParticipant({required this.uid, required this.name, this.photoUrl = ''});

  ChatParticipant copyWith({String? uid, String? name, String? photoUrl}) {
    return ChatParticipant(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatParticipant &&
          other.uid == uid &&
          other.name == name &&
          other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(uid, name, photoUrl);
}
