import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/account_functions_service.dart';
import '../datasources/settings_preferences_service.dart';

class SettingsRepository implements ISettingsRepository {
  final AccountFunctionsService _functions;
  final SettingsPreferencesService _preferences;

  SettingsRepository({
    AccountFunctionsService? functions,
    SettingsPreferencesService? preferences,
  })  : _functions = functions ?? AccountFunctionsService(),
        _preferences = preferences ?? SettingsPreferencesService();

  @override
  Future<void> deleteAccount() => _functions.deleteAccount();

  @override
  Future<bool> getNotificationsEnabled() => _preferences.getNotificationsEnabled();

  @override
  Future<bool> getCallNotificationsEnabled() => _preferences.getCallNotificationsEnabled();

  @override
  Future<String> getAppVersion() => _preferences.getAppVersion();
}
