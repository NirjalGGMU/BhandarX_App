import 'package:bhandarx_flutter/core/constants/hive_table_constant.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter(HiveTableConstant.dbName);
    } else {
      await Hive.initFlutter(HiveTableConstant.dbName);
    }
    _registerAdapters();
    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    }
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    final emailExists = _authBox.values.any(
      (user) => user.email.toLowerCase() == model.email.toLowerCase(),
    );
    if (emailExists) {
      throw Exception('Email already registered');
    }
    await _authBox.put(model.authId, model);
    return model;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      return _authBox.values.firstWhere(
        (user) =>
            user.email.toLowerCase() == email.toLowerCase() &&
            user.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Future<AuthHiveModel?> getCurrentUser(String authId) async {
    if (authId.isEmpty) {
      return null;
    }
    return _authBox.get(authId);
  }

  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<AuthHiveModel?> getUserById(String authId) async {
    return _authBox.get(authId);
  }

  Future<bool> updateUser(AuthHiveModel model) async {
    if (model.authId == null) {
      return false;
    }
    await _authBox.put(model.authId, model);
    return true;
  }

  Future<bool> deleteUser(String authId) async {
    await _authBox.delete(authId);
    return true;
  }

  Future<void> logoutUser() async {}
}
