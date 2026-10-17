import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeetcoach/core/constants/preference_keys.dart';

class SettingsPreferencesService {
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PreferenceKeys.notificationsEnabled) ?? true;
  }

  Future<bool> getCallNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PreferenceKeys.callNotificationsEnabled) ?? true;
  }

  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.buildNumber.isEmpty ? info.version : '${info.version} (${info.buildNumber})';
  }
}
