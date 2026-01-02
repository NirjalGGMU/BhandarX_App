import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:bhandarx_flutter/core/services/hive/hive_service.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_hive_model.dart';

// import 'package:vedaverse/core/services/hive/hive_service.dart';
// import 'package:vedaverse/features/auth/data/datasources/auth_datasource.dart';
// import 'package:vedaverse/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<IAuthDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      return await _hiveService.loginUser(email, password);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return true;
    } catch (e) {
      return false;
    }
  }
}
