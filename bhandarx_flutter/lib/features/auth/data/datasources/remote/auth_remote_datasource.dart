import 'dart:io';

import 'package:bhandarx_flutter/core/api/api_client.dart';
import 'package:bhandarx_flutter/core/api/api_endpoints.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) {
      await _apiClient.saveToken(token);
    }
    return AuthApiModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.register,
      data: user.toRegisterJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) {
      await _apiClient.saveToken(token);
    }
    return AuthApiModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthApiModel> getCurrentUser() async {
    final response = await _apiClient.dio.get(ApiEndpoints.me);
    return AuthApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    return getCurrentUser();
  }

  @override
  Future<AuthApiModel> updateProfile(AuthApiModel user) async {
    final response = await _apiClient.dio.put(
      ApiEndpoints.updateProfile,
      data: user.toProfileJson(),
    );
    return AuthApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthApiModel> uploadProfileImage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'profileImage': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });
    final response = await _apiClient.dio.post(
      '/users/profile/image',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return AuthApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.dio.put(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return true;
  }

  @override
  Future<String?> forgotPassword(String email) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    final data = response.data['data'] as Map<String, dynamic>?;
    return data?['devOtp'] as String?;
  }

  @override
  Future<AuthApiModel> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.resetPassword(token),
      data: {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final jwt = data['token'] as String?;
    if (jwt != null) {
      await _apiClient.saveToken(jwt);
    }
    return AuthApiModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthApiModel> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.resetPasswordOtp,
      data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final jwt = data['token'] as String?;
    if (jwt != null) {
      await _apiClient.saveToken(jwt);
    }
    return AuthApiModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
