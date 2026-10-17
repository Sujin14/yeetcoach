import 'package:flutter/foundation.dart';

/// Debug-only logging. Stripped from release builds by Dart's assert mechanism.
void logDebug(String message) {
  assert(() {
    debugPrint(message);
    return true;
  }());
}
