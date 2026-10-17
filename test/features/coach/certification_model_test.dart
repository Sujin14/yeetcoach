import 'package:flutter_test/flutter_test.dart';
import 'package:yeetcoach/features/coach/data/models/coach_profile_model.dart';

void main() {
  // ── CertificationModel.fromMap ────────────────────────────────────────
  group('CertificationModel.fromMap', () {
    test('parses all fields from a complete map', () {
      final cert = CertificationModel.fromMap(
        {'title': 'ACE CPT', 'issuer': 'ACE', 'year': 2022},
      );
      expect(cert.title,  'ACE CPT');
      expect(cert.issuer, 'ACE');
      expect(cert.year,   2022);
    });

    test('defaults title to empty string when absent', () {
      expect(CertificationModel.fromMap({'issuer': 'ACE', 'year': 2020}).title, '');
    });

    test('defaults issuer to empty string when absent', () {
      expect(CertificationModel.fromMap({'title': 'CPT', 'year': 2020}).issuer, '');
    });

    test('defaults year to 0 when absent', () {
      expect(CertificationModel.fromMap({'title': 'CPT', 'issuer': 'ACE'}).year, 0);
    });

    test('handles empty map with all defaults', () {
      final cert = CertificationModel.fromMap({});
      expect(cert.title,  '');
      expect(cert.issuer, '');
      expect(cert.year,   0);
    });

    test('coerces double year to int', () {
      final cert = CertificationModel.fromMap(
        {'title': 'CPT', 'issuer': 'ACE', 'year': 2021.0},
      );
      expect(cert.year, 2021);
    });
  });

  // ── CertificationModel.toMap ──────────────────────────────────────────
  group('CertificationModel.toMap', () {
    test('round-trips through fromMap → toMap', () {
      final original = {'title': 'NSCA CSCS', 'issuer': 'NSCA', 'year': 2023};
      expect(CertificationModel.fromMap(original).toMap(), equals(original));
    });

    test('writes all three keys', () {
      final map = CertificationModel(
        title: 'FMS', issuer: 'Gray Institute', year: 2019,
      ).toMap();
      expect(map.keys, containsAll(['title', 'issuer', 'year']));
    });
  });
}
