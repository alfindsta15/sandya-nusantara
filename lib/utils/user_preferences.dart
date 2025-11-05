import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _classKey = 'user_class';
  static const String _lastLoginKey = 'last_login';
  static const String _moduleProgressPrefix = 'module_progress_';

  // Save user name
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  // Get user name
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '';
  }

  // Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  // Get user email
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? '';
  }

  // Save login status
  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  // Get login status
  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save user class
  static Future<void> saveUserClass(String userClass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_classKey, userClass);
  }

  // Get user class
  static Future<String> getUserClass() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_classKey) ?? '';
  }

  // Save last login time
  static Future<void> saveLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
  }

  // Get last login time
  static Future<DateTime?> getLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString(_lastLoginKey);
    if (lastLoginStr != null) {
      return DateTime.parse(lastLoginStr);
    }
    return null;
  }

  // Save module progress
  static Future<void> saveModuleProgress(String moduleKey, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_moduleProgressPrefix$moduleKey', progress);
  }

  // Get module progress
  static Future<double> getModuleProgress(String moduleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_moduleProgressPrefix$moduleKey') ?? 0.0;
  }

  // Clear all user data (for logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    // Keep the name and email for convenience
  }
}
