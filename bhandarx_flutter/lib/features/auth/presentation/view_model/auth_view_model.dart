import 'dart:io';

import 'package:bhandarx_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:bhandarx_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:bhandarx_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUseCaseProvider);
    _authRepository = ref.read(authRepositoryProvider) as AuthRepository;
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    String role = 'employee',
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );

    final result = await _registerUsecase(
      RegisterUsecaseParams(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
        role: role,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.register,
        successMessage: 'Account created successfully',
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (entity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        entity: entity,
        successMessage: 'Welcome back, ${entity.fullName}',
      ),
    );
  }

  Future<void> checkCurrentUser() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (entity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        entity: entity,
      ),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    final result = await _authRepository.logout();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = const AuthState(status: AuthStatus.unauthenticated),
    );
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String username,
    String? phoneNumber,
  }) async {
    final user = state.entity;
    if (user == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No active user found',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    final result = await _authRepository.updateProfile(
      user.copyWith(
        fullName: fullName,
        email: email,
        username: username,
        phoneNumber: phoneNumber,
      ),
    );

    return result.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
      return false;
    }, (entity) {
      state = state.copyWith(
        status: AuthStatus.profileUpdated,
        entity: entity,
        successMessage: 'Profile updated successfully',
      );
      return true;
    });
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = state.entity?.authId;
    if (userId == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No active user found',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    final result = await _authRepository.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
      return false;
    }, (_) {
      state = state.copyWith(
        status: AuthStatus.profileUpdated,
        successMessage: 'Password changed successfully',
      );
      return true;
    });
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    final result = await _authRepository.resetPasswordWithToken(
      token: token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    return result.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
      return false;
    }, (entity) {
      state = state.copyWith(
        status: AuthStatus.passwordReset,
        entity: entity,
        successMessage: 'Password reset successfully',
      );
      return true;
    });
  }

  Future<String?> requestPasswordReset(String email) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    final result = await _authRepository.requestPasswordReset(email);
    return result.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
      return null;
    }, (devOtp) {
      state = state.copyWith(
        status: AuthStatus.passwordReset,
        successMessage: 'Reset request sent successfully',
      );
      return devOtp;
    });
  }

  Future<bool> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    final result = await _authRepository.resetPasswordWithOtp(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    return result.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
      return false;
    }, (entity) {
      state = state.copyWith(
        status: AuthStatus.passwordReset,
        entity: entity,
        successMessage: 'Password reset successfully',
      );
      return true;
    });
  }

  Future<bool> saveUser(AuthEntity entity) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    final result = await _authRepository.updateProfile(entity);
    return result.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
      return false;
    }, (updatedEntity) {
      state = state.copyWith(
        status: AuthStatus.profileUpdated,
        entity: updatedEntity,
        successMessage: 'Preferences updated',
      );
      return true;
    });
  }

  Future<bool> uploadProfileImage(File imageFile) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    final result = await _authRepository.uploadProfileImage(imageFile);
    return result.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
      return false;
    }, (updatedEntity) {
      state = state.copyWith(
        status: AuthStatus.profileUpdated,
        entity: updatedEntity,
        successMessage: 'Profile image updated',
      );
      return true;
    });
  }

  void setUser(AuthEntity entity) {
    state = state.copyWith(status: AuthStatus.authenticated, entity: entity);
  }
}
