import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:bhandarx_flutter/core/constants/hive_table_constant.dart';
import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';


// INFO: dart run build_runner build -d
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
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.profilePicture,
  }) : authId = Uuid().v4();

  // Info: To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      profilePicture: profilePicture,
    );
  }

  // Info: From Entity (factory function)
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  // Info: To entity list (static function)
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}