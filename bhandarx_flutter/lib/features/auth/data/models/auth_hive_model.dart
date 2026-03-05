import 'package:bhandarx_flutter/core/constants/hive_table_constant.dart';
import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String role;

  @HiveField(6)
  final String? phoneNumber;

  @HiveField(7)
  final String? profilePicture;

  @HiveField(8)
  final bool notificationsEnabled;

  @HiveField(9)
  final bool emailAlertsEnabled;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.role = 'employee',
    this.phoneNumber,
    this.profilePicture,
    this.notificationsEnabled = true,
    this.emailAlertsEnabled = true,
  }) : authId = authId ?? const Uuid().v4();

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      role: role,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      notificationsEnabled: notificationsEnabled,
      emailAlertsEnabled: emailAlertsEnabled,
    );
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      role: entity.role,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
      notificationsEnabled: entity.notificationsEnabled,
      emailAlertsEnabled: entity.emailAlertsEnabled,
    );
  }
}
