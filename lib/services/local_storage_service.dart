import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Settings
  static Future<void> saveThemeMode(String themeMode) async {
    await _prefs?.setString('themeMode', themeMode);
  }

  static String? getThemeMode() {
    return _prefs?.getString('themeMode');
  }

  static Future<void> saveLanguageCode(String languageCode) async {
    await _prefs?.setString('languageCode', languageCode);
  }

  static String? getLanguageCode() {
    return _prefs?.getString('languageCode');
  }

  // User ID (for anonymous auth)
  static Future<void> saveUserId(String userId) async {
    final prefs = await initialize();
    await prefs.setString('userId', userId);
  }

  static String? getUserId() {
    return _prefs?.getString('userId');
  }
}

