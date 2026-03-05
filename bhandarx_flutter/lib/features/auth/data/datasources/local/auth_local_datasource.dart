import 'package:bhandarx_flutter/core/services/hive/hive_service.dart';
import 'package:bhandarx_flutter/core/services/storage/user_session_service.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLocalDatasourceProvider = Provider<IAuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final sessionService = ref.watch(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    sessionService: sessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _sessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService sessionService,
  }) : _hiveService = hiveService,
       _sessionService = sessionService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    final userId = _sessionService.getUserId();
    if (userId == null) {
      return null;
    }
    return _hiveService.getCurrentUser(userId);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) {
    return _hiveService.loginUser(email, password);
  }

  @override
  Future<bool> logout() async {
    await _hiveService.logoutUser();
    await _sessionService.clearSession();
    return true;
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel model) {
    return _hiveService.registerUser(model);
  }

  @override
  Future<bool> deleteUser(String authId) {
    return _hiveService.deleteUser(authId);
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) {
    return _hiveService.getUserByEmail(email);
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) {
    return _hiveService.getUserById(authId);
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) {
    return _hiveService.updateUser(user);
  }
}
