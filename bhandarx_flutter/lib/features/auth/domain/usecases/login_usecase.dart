import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhandarx_flutter/core/error/failures.dart';
import 'package:bhandarx_flutter/core/usecase/app_usecase.dart';
import 'package:bhandarx_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:bhandarx_flutter/features/auth/domain/repositories/auth_repository.dart';





// Provider
final loginUseCaseProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUsecase
    implements UseCaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
