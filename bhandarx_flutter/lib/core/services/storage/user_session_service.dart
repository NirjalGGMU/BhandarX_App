import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferenceProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences must be initialized in main.dart');
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(
      sharedPreference: ref.read(sharedPreferenceProvider));
});

class UserSessionService {
  final SharedPreferences _sharedPreferences;

  UserSessionService({required SharedPreferences sharedPreference})
      : _sharedPreferences = sharedPreference;

  static const String _keysIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUsername = 'username';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserProfileImage = 'user_profile_image';
  static const String _keyDarkMode = 'dark_mode_enabled';
  static const String _keyOnboardingSeen = 'onboarding_seen';
  static const String _keyLanguageCode = 'language_code';

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
    required String fullName,
    required String role,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    await _sharedPreferences.setBool(_keysIsLoggedIn, true);
    await _sharedPreferences.setString(_keyUserId, userId);
    await _sharedPreferences.setString(_keyUserEmail, email);
    await _sharedPreferences.setString(_keyUsername, username);
    await _sharedPreferences.setString(_keyUserFullName, fullName);
    await _sharedPreferences.setString(_keyUserRole, role);
    if (phoneNumber != null) {
      await _sharedPreferences.setString(_keyUserPhoneNumber, phoneNumber);
    }
    if (profilePicture != null) {
      await _sharedPreferences.setString(_keyUserProfileImage, profilePicture);
    }
  }

  Future<void> clearSession() async {
    await _sharedPreferences.remove(_keysIsLoggedIn);
    await _sharedPreferences.remove(_keyUserId);
    await _sharedPreferences.remove(_keyUserEmail);
    await _sharedPreferences.remove(_keyUsername);
    await _sharedPreferences.remove(_keyUserFullName);
    await _sharedPreferences.remove(_keyUserPhoneNumber);
    await _sharedPreferences.remove(_keyUserRole);
    await _sharedPreferences.remove(_keyUserProfileImage);
  }

  bool isLoggedIn() => _sharedPreferences.getBool(_keysIsLoggedIn) ?? false;
  String? getUserId() => _sharedPreferences.getString(_keyUserId);
  String? getUserEmail() => _sharedPreferences.getString(_keyUserEmail);
  String? getUsername() => _sharedPreferences.getString(_keyUsername);
  String? getUserFullName() => _sharedPreferences.getString(_keyUserFullName);
  String? getUserPhoneNumber() =>
      _sharedPreferences.getString(_keyUserPhoneNumber);
  String? getUserRole() => _sharedPreferences.getString(_keyUserRole);
  String? getUserProfileImage() =>
      _sharedPreferences.getString(_keyUserProfileImage);

  Future<void> setDarkMode(bool value) async {
    await _sharedPreferences.setBool(_keyDarkMode, value);
  }

  bool isDarkModeEnabled() => _sharedPreferences.getBool(_keyDarkMode) ?? false;

  Future<void> setOnboardingSeen(bool value) async {
    await _sharedPreferences.setBool(_keyOnboardingSeen, value);
  }

  bool hasSeenOnboarding() =>
      _sharedPreferences.getBool(_keyOnboardingSeen) ?? false;

  Future<void> setLanguageCode(String code) async {
    await _sharedPreferences.setString(_keyLanguageCode, code);
  }

  String getLanguageCode() =>
      _sharedPreferences.getString(_keyLanguageCode) ?? 'en';
}
