import 'package:bhandarx_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_hive_model.dart';
import 'dart:io';

abstract interface class IAuthLocalDatasource {
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<AuthHiveModel?> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(String authId);
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String authId);
  Future<AuthApiModel> getCurrentUser();
  Future<AuthApiModel> updateProfile(AuthApiModel user);
  Future<AuthApiModel> uploadProfileImage(File imageFile);
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<String?> forgotPassword(String email);
  Future<AuthApiModel> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });
  Future<AuthApiModel> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
}
