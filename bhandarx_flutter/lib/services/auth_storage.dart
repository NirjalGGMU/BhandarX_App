// lib/services/auth_storage.dart

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _keyEmail = "user_email";
  static const String _keyPassword = "user_password";

  // Save user credentials (frontend only)
  static Future<void> saveUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  // Get saved user (returns null if none)
  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);
    if (email == null || password == null) return null;
    return {"email": email, "password": password};
  }

  // Returns true if a user exists in storage
  static Future<bool> hasUser() async => await getUser() != null;

  // NEW: Validate email & password against saved credentials
  // Returns true when both match the stored values.
  static Future<bool> validateUser(String email, String password) async {
    final user = await getUser();
    if (user == null) return false;
    return user["email"] == email && user["password"] == password;
  }

  // OPTIONAL: Clear user (useful for logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
  }
}



// lib/services/auth_storage.dart

// import 'package:shared_preferences/shared_preferences.dart';

// class AuthStorage {
//   static const String _keyEmail = "user_email";
//   static const String _keyPassword = "user_password";

//   // Save user credentials (frontend only)
//   static Future<void> saveUser(String email, String password) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_keyEmail, email);
//     await prefs.setString(_keyPassword, password);
//   }

//   // Get saved user (returns null if none)
//   static Future<Map<String, String>?> getUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final email = prefs.getString(_keyEmail);
//     final password = prefs.getString(_keyPassword);
//     if (email == null || password == null) return null;
//     return {"email": email, "password": password};
//   }

//   // Returns true if a user exists in storage
//   static Future<bool> hasUser() async => await getUser() != null;

//   // NEW: Validate email & password against saved credentials
//   // Returns true when both match the stored values.
//   static Future<bool> validateUser(String email, String password) async {
//     final user = await getUser();
//     if (user == null) return false;
//     return user["email"] == email && user["password"] == password;
//   }

//   // OPTIONAL: Clear user (useful for logout)
//   static Future<void> clearUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyEmail);
//     await prefs.remove(_keyPassword);
//   }
// }
