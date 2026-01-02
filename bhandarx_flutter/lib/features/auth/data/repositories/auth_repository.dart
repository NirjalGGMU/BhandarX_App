import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhandarx_flutter/core/error/failures.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_hive_model.dart';
import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:bhandarx_flutter/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.watch(authLocalDatasourceProvider);
  return AuthRepository(authDatasource: authDatasource);
});

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;

  AuthRepository({required IAuthDatasource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final model = await _authDatasource.login(email, password);

      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }

      return Left(LocalDataBaseFailure(message: "User not found"));
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) return Right(true);
      return Left(LocalDataBaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      if (result) return Right(true);
      return Left(LocalDataBaseFailure(message: "Failed to register user"));
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }
}
