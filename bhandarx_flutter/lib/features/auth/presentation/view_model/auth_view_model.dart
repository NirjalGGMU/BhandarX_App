// lib/features/auth/presentation/view_model/auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhandarx_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:bhandarx_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';

// Notifier provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUseCaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
    );

    try {
      final result = await _registerUsecase(params);
      result.fold(
        (left) => state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: left.message,
        ),
        (success) {
          if (success) {
            state = state.copyWith(status: AuthStatus.register, errorMessage: null);
          } else {
            state = state.copyWith(
              status: AuthStatus.error,
              errorMessage: "Registration Failed",
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = LoginUsecaseParams(email: email, password: password);

    try {
      final result = await _loginUsecase(params);
      result.fold(
        (left) => state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: left.message,
        ),
        (entity) => state = state.copyWith(
          status: AuthStatus.authenticated,
          entity: entity,
          errorMessage: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  Future<void> checkCurrentUser() async {
    // Implement if needed, e.g., check token and get user
  }
}



// // lib/features/auth/presentation/view_model/auth_view_model.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:bhandarx_flutter/features/auth/domain/usecases/login_usecase.dart';
// import 'package:bhandarx_flutter/features/auth/domain/usecases/register_usecase.dart';
// import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';

// // Notifier provider
// final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
//   () => AuthViewModel(),
// );

// class AuthViewModel extends Notifier<AuthState> {
//   late final RegisterUsecase _registerUsecase;
//   late final LoginUsecase _loginUsecase;

//   @override
//   AuthState build() {
//     _registerUsecase = ref.read(registerUsecaseProvider);
//     _loginUsecase = ref.read(loginUseCaseProvider);
//     return AuthState();
//   }

//   Future<void> register({
//     required String fullName,
//     required String username,
//     required String email,
//     required String password,
//     required String confirmPassword,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     final params = RegisterUsecaseParams(
//       fullName: fullName,
//       email: email,
//       username: username,
//       password: password,
//       confirmPassword: confirmPassword,
//     );

//     final result = await _registerUsecase(params);

//     result.fold(
//       (left) => state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: left.message,
//       ),
//       (success) {
//         if (success) {
//           state = state.copyWith(status: AuthStatus.register);
//         } else {
//           state = state.copyWith(
//             status: AuthStatus.error,
//             errorMessage: "Registration Failed",
//           );
//         }
//       },
//     );
//   }

//   // Login
//   Future<void> login({required String email, required String password}) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     final params = LoginUsecaseParams(email: email, password: password);
//     final result = await _loginUsecase(params);

//     result.fold(
//       (left) => state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: left.message,
//       ),
//       (entity) => state = state.copyWith(
//         status: AuthStatus.authenticated,
//         entity: entity,
//       ),
//     );
//   }

//   Future<void> checkCurrentUser() async {}
// }