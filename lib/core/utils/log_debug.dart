import 'package:flutter/foundation.dart';

/// Debug-only logging. No-ops in release; uses [debugPrint] so messages reach logcat.
void logDebug(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
