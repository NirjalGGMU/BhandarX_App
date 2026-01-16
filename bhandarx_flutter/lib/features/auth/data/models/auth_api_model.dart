import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String? phoneNumber;
  final String? profilePicture;

  AuthApiModel({
    this.authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.phoneNumber,
    this.profilePicture,
  });

  // info: To JSON
  Map<String, dynamic> toJson() {
    return {
      "name": fullName,
      "email": email,
      "username": username,
      "phoneNumber": phoneNumber,
      "password": password,
      "profilePicture": profilePicture,
    };
  }

  // info: from JSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json["_id"] as String,
      fullName: json["name"] as String,
      email: json["email"] as String,
      username: json["username"] as String,
      phoneNumber: json["phoneNumber"] as String?,
      profilePicture: json["profilePicture"] as String?,
    );
  }

  // info: to entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      username: username,
      profilePicture: profilePicture,
    );
  }

  // info: from entity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      username: entity.username,
      profilePicture: entity.profilePicture,

    );
  }

  // info: to entity list
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}