import 'dart:io';

import 'package:bhandarx_flutter/core/api/api_client.dart';
import 'package:bhandarx_flutter/core/error/failures.dart';
import 'package:bhandarx_flutter/core/services/connectivity/network_info.dart';
import 'package:bhandarx_flutter/core/services/storage/user_session_service.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_hive_model.dart';
import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:bhandarx_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDatasource = ref.watch(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.watch(authRemoteDatasourceProvider);
  final sessionService = ref.watch(userSessionServiceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(
    authLocalDatasource: authLocalDatasource,
    authRemoteDatasource: authRemoteDatasource,
    sessionService: sessionService,
    networkInfo: networkInfo,
    apiClient: apiClient,
  );
});

class AuthRepository implements IAuthRepository {
  AuthRepository({
    required IAuthLocalDatasource authLocalDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required UserSessionService sessionService,
    required NetworkInfo networkInfo,
    required ApiClient apiClient,
  }) : _authLocalDatasource = authLocalDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _sessionService = sessionService,
       _networkInfo = networkInfo,
       _apiClient = apiClient;

  final IAuthLocalDatasource _authLocalDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final UserSessionService _sessionService;
  final NetworkInfo _networkInfo;
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final remoteUser = await _authRemoteDatasource.register(
        AuthApiModel.fromEntity(entity),
      );
      await _cacheUser(remoteUser.toEntity().copyWith(password: entity.password));
      return const Right(true);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallback: 'Registration failed'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final remoteUser = await _authRemoteDatasource.login(email, password);
      if (remoteUser == null) {
        return const Left(ApiFailure(message: 'Invalid email or password'));
      }
      final entity = remoteUser.toEntity().copyWith(password: password);
      await _cacheUser(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallback: 'Login failed'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteUser = await _authRemoteDatasource.getCurrentUser();
        final cachedUser = remoteUser.toEntity().copyWith(
          password: (await _authLocalDatasource.getUserById(
            remoteUser.authId ?? '',
          ))?.password,
        );
        await _cacheUser(cachedUser);
        return Right(cachedUser);
      } on DioException catch (e) {
        final localUser = await _authLocalDatasource.getCurrentUser();
        if (localUser != null) {
          return Right(localUser.toEntity());
        }
        return Left(_mapDioFailure(e, fallback: 'Unable to load profile'));
      }
    }

    final localUser = await _authLocalDatasource.getCurrentUser();
    if (localUser == null) {
      return const Left(LocalDatabaseFailure(message: 'No logged in user'));
    }
    return Right(localUser.toEntity());
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _apiClient.clearToken();
      await _authLocalDatasource.logout();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile(AuthEntity entity) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final updatedRemote = await _authRemoteDatasource.updateProfile(
        AuthApiModel.fromEntity(entity),
      );
      final existing = entity.authId == null
          ? null
          : await _authLocalDatasource.getUserById(entity.authId!);
      final updatedEntity = updatedRemote.toEntity().copyWith(
        password: entity.password ?? existing?.password,
        notificationsEnabled: entity.notificationsEnabled,
        emailAlertsEnabled: entity.emailAlertsEnabled,
      );
      await _cacheUser(updatedEntity);
      return Right(updatedEntity);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallback: 'Failed to update profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> uploadProfileImage(File imageFile) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final remoteUser = await _authRemoteDatasource.uploadProfileImage(imageFile);
      final existing = remoteUser.authId == null
          ? null
          : await _authLocalDatasource.getUserById(remoteUser.authId!);
      final entity = remoteUser.toEntity().copyWith(
        password: existing?.password,
        notificationsEnabled:
            existing?.notificationsEnabled ?? remoteUser.notificationsEnabled,
        emailAlertsEnabled:
            existing?.emailAlertsEnabled ?? remoteUser.emailAlertsEnabled,
      );
      await _cacheUser(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallback: 'Failed to upload profile image'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      await _authRemoteDatasource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final currentUser = await _authLocalDatasource.getUserById(userId);
      if (currentUser != null) {
        await _authLocalDatasource.updateUser(
          AuthHiveModel.fromEntity(
            currentUser.toEntity().copyWith(password: newPassword),
          ),
        );
      }
      return const Right(true);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallback: 'Failed to change password'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    return const Left(
      ApiFailure(message: 'Use the reset token flow to reset password'),
    );
  }

  @override
  Future<Either<Failure, String?>> requestPasswordReset(String email) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final devOtp = await _authRemoteDatasource.forgotPassword(email);
      return Right(devOtp);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallback: 'Failed to request password reset'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> resetPasswordWithToken({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final remoteUser = await _authRemoteDatasource.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      final entity = remoteUser.toEntity().copyWith(password: newPassword);
      await _cacheUser(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallback: 'Failed to reset password'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final remoteUser = await _authRemoteDatasource.resetPasswordWithOtp(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      final entity = remoteUser.toEntity().copyWith(password: newPassword);
      await _cacheUser(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallback: 'Failed to reset password'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<void> _cacheUser(AuthEntity entity) async {
    final success = await _authLocalDatasource.updateUser(
      AuthHiveModel.fromEntity(entity),
    );
    if (!success && entity.authId != null) {
      await _authLocalDatasource.register(AuthHiveModel.fromEntity(entity));
    }
    await _persistSession(entity);
  }

  Future<void> _persistSession(AuthEntity entity) {
    return _sessionService.saveUserSession(
      userId: entity.authId ?? '',
      email: entity.email,
      username: entity.username,
      fullName: entity.fullName,
      role: entity.role,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
    );
  }

  Failure _mapDioFailure(DioException exception, {required String fallback}) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final first = (data['errors'] as List).first;
        if (first is Map<String, dynamic> && first['msg'] is String) {
          return ApiFailure(
            message: first['msg'] as String,
            statusCode: exception.response?.statusCode,
          );
        }
      }
      if (data['message'] is String) {
        return ApiFailure(
          message: data['message'] as String,
          statusCode: exception.response?.statusCode,
        );
      }
    }
    return ApiFailure(
      message: fallback,
      statusCode: exception.response?.statusCode,
    );
  }
}
