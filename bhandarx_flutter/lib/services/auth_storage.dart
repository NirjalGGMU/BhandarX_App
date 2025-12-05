import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _keyEmail = "user_email";
  static const String _keyPassword = "user_password";

  static Future<void> saveUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);
    if (email == null || password == null) return null;
    return {"email": email, "password": password};
  }

  static Future<bool> hasUser() async => await getUser() != null;
}