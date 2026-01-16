// lib/core/services/storage/user_session_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Note: Provider for shared preference
final sharedPreferenceProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    "Shared pref main.dart bata implement garne ho. Timi dukha basa ma dinxu",
  );
});

//Note: Provider for user Session service
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(
    sharedPreference: ref.read(sharedPreferenceProvider),
  );
});

class UserSessionService {
  final SharedPreferences _sharedPreferences;

  UserSessionService({required SharedPreferences sharedPreference})
    : _sharedPreferences = sharedPreference;

  // keys for storing data
  static const String _keysIsLoggedIn = "is_logged_in";
  static const String _keyUserId = "user_id";
  static const String _keyUserEmail = "user_email";
  static const String _keyUsername = "username";
  static const String _keyUserFullName = "user_full_name";
  static const String _keyUserPhoneNumber = "user_phone_number";
  static const String _keyUserBatchId = "user_batch_id";
  static const String _keyUserProfileImage = "user_profile_image";

  // Removed the incomplete method as it is not implemented and causes a syntax error.

  // Info: save user session data
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
    required String fullName,
    required String? phoneNumber,
    required String? batchId,
    String? profilePicture,
  }) async {
    await _sharedPreferences.setBool(_keysIsLoggedIn, true);
    await _sharedPreferences.setString(_keyUserId, userId);
    await _sharedPreferences.setString(_keyUserEmail, email);
    await _sharedPreferences.setString(_keyUsername, username);
    await _sharedPreferences.setString(_keyUserFullName, fullName);
    if (phoneNumber != null) {
      await _sharedPreferences.setString(_keyUserPhoneNumber, phoneNumber);
    }
    if (batchId != null) {
      await _sharedPreferences.setString(_keyUserBatchId, batchId);
    }
    if (profilePicture != null) {
      await _sharedPreferences.setString(_keyUserProfileImage, profilePicture);
    }
  }

  //Info: Clear user session
  Future<void> clearSession() async {
    await _sharedPreferences.remove(_keysIsLoggedIn);
    await _sharedPreferences.remove(_keyUserId);
    await _sharedPreferences.remove(_keyUserEmail);
    await _sharedPreferences.remove(_keyUsername);
    await _sharedPreferences.remove(_keyUserFullName);
    await _sharedPreferences.remove(_keyUserPhoneNumber);
    await _sharedPreferences.remove(_keyUserBatchId);
    await _sharedPreferences.remove(_keyUserProfileImage);
  }

  // Info: getter
  bool isLoggedIn() {
    return _sharedPreferences.getBool(_keysIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _sharedPreferences.getString(_keyUserId);
  }

  String? getUserEmail() {
    return _sharedPreferences.getString(_keyUserEmail);
  }

  String? getUsername() {
    return _sharedPreferences.getString(_keyUsername);
  }

  String? getUserFullName() {
    return _sharedPreferences.getString(_keyUserFullName);
  }

  String? getUserPhoneNumber() {
    return _sharedPreferences.getString(_keyUserPhoneNumber);
  }

  String? getUserBatchId() {
    return _sharedPreferences.getString(_keyUserBatchId);
  }

  String? getUserProfileImage() {
    return _sharedPreferences.getString(_keyUserProfileImage);
  }
}