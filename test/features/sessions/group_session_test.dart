import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetcoach/features/sessions/data/models/group_session_model.dart';
import 'package:yeetcoach/features/sessions/domain/entities/group_session.dart';

void main() {
  final scheduledAt = DateTime(2025, 6, 15, 10, 30);
  final createdAt   = DateTime(2025, 6, 10, 8, 0);

  GroupSession baseSession() => GroupSession(
        id: 'sess1',
        coachUid: 'coach123',
        title: 'Morning HIIT',
        meetLink: 'https://meet.google.com/abc-xyz',
        scheduledAt: scheduledAt,
        createdAt: createdAt,
      );

  // ── GroupSession entity ───────────────────────────────────────────────
  group('GroupSession.isToday', () {
    test('returns true when scheduledAt is today', () {
      final now = DateTime.now();
      final s = baseSession().copyWith(
        scheduledAt: DateTime(now.year, now.month, now.day, 9, 0),
      );
      expect(s.isToday, isTrue);
    });

    test('returns false when scheduledAt is a different day', () {
      expect(baseSession().isToday, isFalse);
    });
  });

  group('GroupSession.copyWith', () {
    test('returns equal object when no overrides provided', () {
      expect(baseSession().copyWith(), equals(baseSession()));
    });

    test('overrides title only', () {
      final updated = baseSession().copyWith(title: 'Evening Yoga');
      expect(updated.title, 'Evening Yoga');
      expect(updated.id, 'sess1');
      expect(updated.coachUid, 'coach123');
    });

    test('overrides durationMinutes', () {
      expect(baseSession().copyWith(durationMinutes: 45).durationMinutes, 45);
    });

    test('overrides description from null to a value', () {
      expect(
        baseSession().copyWith(description: 'Bring your mat').description,
        'Bring your mat',
      );
    });
  });

  group('GroupSession equality', () {
    test('two sessions with the same fields are equal', () {
      expect(baseSession(), equals(baseSession()));
    });

    test('differs when id differs', () {
      expect(baseSession(), isNot(equals(baseSession().copyWith(id: 'other'))));
    });

    test('differs when title differs', () {
      expect(baseSession(), isNot(equals(baseSession().copyWith(title: 'X'))));
    });

    test('differs when durationMinutes differs', () {
      expect(
        baseSession(),
        isNot(equals(baseSession().copyWith(durationMinutes: 45))),
      );
    });
  });

  group('GroupSession.hashCode', () {
    test('equal objects share the same hashCode', () {
      expect(baseSession().hashCode, equals(baseSession().hashCode));
    });
  });

  // ── GroupSessionModel.fromMap ─────────────────────────────────────────
  group('GroupSessionModel.fromMap', () {
    test('parses all fields from a complete map', () {
      final map = {
        'coachUid':        'coach123',
        'title':           'Morning HIIT',
        'meetLink':        'https://meet.google.com/abc',
        'scheduledAt':     Timestamp.fromDate(scheduledAt),
        'durationMinutes': 45,
        'description':     'Bring your mat',
        'createdAt':       Timestamp.fromDate(createdAt),
      };
      final m = GroupSessionModel.fromMap('sess1', map);
      expect(m.id,              'sess1');
      expect(m.coachUid,        'coach123');
      expect(m.title,           'Morning HIIT');
      expect(m.meetLink,        'https://meet.google.com/abc');
      expect(m.scheduledAt,     scheduledAt);
      expect(m.durationMinutes, 45);
      expect(m.description,     'Bring your mat');
      expect(m.createdAt,       createdAt);
    });

    test('defaults durationMinutes to 60 when absent', () {
      final map = {
        'coachUid':    'c',
        'title':       'T',
        'meetLink':    'https://meet.google.com/x',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'createdAt':   Timestamp.fromDate(createdAt),
      };
      expect(GroupSessionModel.fromMap('id', map).durationMinutes, 60);
    });

    test('maps empty description to null', () {
      final map = {
        'coachUid':    'c',
        'title':       'T',
        'meetLink':    'https://meet.google.com/x',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'createdAt':   Timestamp.fromDate(createdAt),
        'description': '',
      };
      expect(GroupSessionModel.fromMap('id', map).description, isNull);
    });

    test('maps whitespace-only description to null', () {
      final map = {
        'coachUid':    'c',
        'title':       'T',
        'meetLink':    'https://meet.google.com/x',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'createdAt':   Timestamp.fromDate(createdAt),
        'description': '   ',
      };
      expect(GroupSessionModel.fromMap('id', map).description, isNull);
    });

    test('accepts int millis for scheduledAt via FirestoreParsing', () {
      final millis = scheduledAt.millisecondsSinceEpoch;
      final map = {
        'coachUid':    'c',
        'title':       'T',
        'meetLink':    'https://meet.google.com/x',
        'scheduledAt': millis,
        'createdAt':   Timestamp.fromDate(createdAt),
      };
      expect(
        GroupSessionModel.fromMap('id', map).scheduledAt.millisecondsSinceEpoch,
        millis,
      );
    });
  });

  // ── GroupSessionModel.toMap ───────────────────────────────────────────
  group('GroupSessionModel.toMap', () {
    const name  = 'Alex Coach';
    const photo = 'https://example.com/photo.jpg';

    GroupSessionModel make({int mins = 60, String? description}) =>
        GroupSessionModel(
          id: 'sess1',
          coachUid: 'coach123',
          title: 'Morning HIIT',
          meetLink: 'https://meet.google.com/abc',
          scheduledAt: scheduledAt,
          durationMinutes: mins,
          description: description,
          createdAt: createdAt,
        );

    test('includes all YeetFit-required fields', () {
      final map = make().toMap(trainerName: name, trainerPhoto: photo);
      expect(map['coachUid'],        'coach123');
      expect(map['trainerId'],        'coach123'); // YeetFit queries by this
      expect(map['trainerName'],      name);
      expect(map['trainerPhoto'],     photo);
      expect(map['title'],            'Morning HIIT');
      expect(map['meetLink'],         'https://meet.google.com/abc');
      expect(map['durationMinutes'],  60);
    });

    test('scheduledAt and createdAt are Timestamps', () {
      final map = make().toMap(trainerName: name, trainerPhoto: photo);
      expect((map['scheduledAt'] as Timestamp).toDate(), scheduledAt);
      expect((map['createdAt']   as Timestamp).toDate(), createdAt);
    });

    test('endsAt = scheduledAt + 45 min', () {
      final map = make(mins: 45).toMap(trainerName: name, trainerPhoto: photo);
      expect(
        (map['endsAt'] as Timestamp).toDate(),
        scheduledAt.add(const Duration(minutes: 45)),
      );
    });

    test('endsAt = scheduledAt + 90 min', () {
      final map = make(mins: 90).toMap(trainerName: name, trainerPhoto: photo);
      expect(
        (map['endsAt'] as Timestamp).toDate(),
        scheduledAt.add(const Duration(minutes: 90)),
      );
    });

    test('description is omitted when null', () {
      final map = make().toMap(trainerName: name, trainerPhoto: photo);
      expect(map.containsKey('description'), isFalse);
    });

    test('description is included when set', () {
      final map = make(description: 'Bring water')
          .toMap(trainerName: name, trainerPhoto: photo);
      expect(map['description'], 'Bring water');
    });
  });
}
