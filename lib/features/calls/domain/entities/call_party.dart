import 'package:flutter/foundation.dart';

/// Display details for one side of a call, denormalised onto calls/{callId}
/// so YeetFit can show who is calling without reading the coach's profile.
@immutable
class CallParty {
  final String uid;
  final String name;
  final String photoUrl;

  const CallParty({required this.uid, required this.name, this.photoUrl = ''});

  CallParty copyWith({String? uid, String? name, String? photoUrl}) {
    return CallParty(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallParty && other.uid == uid && other.name == name && other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(uid, name, photoUrl);
}
