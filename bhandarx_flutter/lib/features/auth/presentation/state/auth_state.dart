import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  register,
  passwordReset,
  profileUpdated,
  error,
}

class AuthState {
  final AuthStatus status;
  final AuthEntity? entity;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.entity,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? entity,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      entity: entity ?? this.entity,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
