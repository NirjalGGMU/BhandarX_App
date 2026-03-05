import 'package:bhandarx_flutter/core/error/failures.dart';
import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> updateProfile(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> uploadProfileImage(File imageFile);
  Future<Either<Failure, bool>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String newPassword,
  });
  Future<Either<Failure, String?>> requestPasswordReset(String email);
  Future<Either<Failure, AuthEntity>> resetPasswordWithToken({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });
  Future<Either<Failure, AuthEntity>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
}
