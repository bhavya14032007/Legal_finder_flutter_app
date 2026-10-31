import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Local Storage Service using SharedPreferences
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Theme Mode (dark, light, system)
  String getThemeMode() {
    return _prefs.getString(AppConstants.prefKeyTheme) ?? 'system';
  }

  Future<bool> setThemeMode(String themeMode) {
    return _prefs.setString(AppConstants.prefKeyTheme, themeMode);
  }

  // Language code ('en', 'hi')
  String getLanguage() {
    return _prefs.getString(AppConstants.prefKeyLanguage) ?? 'en';
  }

  Future<bool> setLanguage(String langCode) {
    return _prefs.setString(AppConstants.prefKeyLanguage, langCode);
  }

  // Notifications enabled
  bool getNotificationsEnabled() {
    return _prefs.getBool(AppConstants.prefKeyNotifications) ?? true;
  }

  Future<bool> setNotificationsEnabled(bool enabled) {
    return _prefs.setBool(AppConstants.prefKeyNotifications, enabled);
  }

  // Clear all data (on full logout/reset)
  Future<bool> clear() {
    return _prefs.clear();
  }
}

