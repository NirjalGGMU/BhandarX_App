import 'package:bhandarx_flutter/features/auth/data/models/auth_hive_model.dart';
// import 'package:vedaverse/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
}