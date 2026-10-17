import 'package:cloud_firestore/cloud_firestore.dart';

/// Lenient readers for Firestore values, which may arrive as num, String, or Timestamp.
abstract final class FirestoreParsing {
  static DateTime toDateTime(Object? value) {
    return switch (value) {
      Timestamp timestamp => timestamp.toDate(),
      DateTime dateTime => dateTime,
      int millis => DateTime.fromMillisecondsSinceEpoch(millis),
      String text => DateTime.tryParse(text) ?? DateTime.fromMillisecondsSinceEpoch(0),
      _ => DateTime.fromMillisecondsSinceEpoch(0),
    };
  }

  static String toStringValue(Object? value) => value?.toString() ?? '';

  static int? toIntOrNull(Object? value) {
    return switch (value) {
      num number => number.toInt(),
      String text => int.tryParse(text.trim()) ?? double.tryParse(text.trim())?.toInt(),
      _ => null,
    };
  }

  static int toInt(Object? value) => toIntOrNull(value) ?? 0;

  static double toDouble(Object? value) {
    return switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text.trim()) ?? 0,
      _ => 0,
    };
  }

  static List<Map<String, dynamic>> toMapList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }
}
