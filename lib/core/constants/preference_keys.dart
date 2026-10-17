/// SharedPreferences keys used by more than one feature.
abstract final class PreferenceKeys {
  /// Whether notifications are shown on this device. Missing means true.
  static const String notificationsEnabled = 'notifications_enabled';

  /// Whether incoming-call alerts are shown on this device. Missing means true.
  static const String callNotificationsEnabled = 'calls_notifications_enabled';
}
