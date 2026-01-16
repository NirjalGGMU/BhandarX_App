// lib/features/auth/presentation/state/auth_state.dart
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  register,
  error,
}

class AuthState {
  final AuthStatus status;
  final dynamic entity;          // Your auth entity/user model
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.entity,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    dynamic entity,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      entity: entity ?? this.entity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}