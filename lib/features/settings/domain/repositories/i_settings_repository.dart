abstract class ISettingsRepository {
  /// Runs the deleteAccount Cloud Function, which removes the coach's data and Auth account.
  Future<void> deleteAccount();

  /// Both default to true. Changed through PushNotificationService, which also syncs the FCM token.
  Future<bool> getNotificationsEnabled();
  Future<bool> getCallNotificationsEnabled();

  /// Version and build from the installed package, which Flutter sets from pubspec.yaml.
  Future<String> getAppVersion();
}
