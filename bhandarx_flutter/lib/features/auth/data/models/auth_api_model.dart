import 'package:bhandarx_flutter/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String role;
  final String? phoneNumber;
  final String? profilePicture;
  final bool notificationsEnabled;
  final bool emailAlertsEnabled;

  AuthApiModel({
    this.authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.role = 'employee',
    this.phoneNumber,
    this.profilePicture,
    this.notificationsEnabled = true,
    this.emailAlertsEnabled = true,
  });

  Map<String, dynamic> toRegisterJson() {
    return {
      'name': fullName,
      'email': email,
      'password': password,
      'role': role,
      if (phoneNumber != null && phoneNumber!.isNotEmpty) 'phone': phoneNumber,
    };
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'name': fullName,
      'email': email,
      if (phoneNumber != null) 'phone': phoneNumber,
      'notificationPreferences': {
        'orders': notificationsEnabled,
        'email': emailAlertsEnabled,
      },
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    final notificationPreferences =
        (json['notificationPreferences'] as Map<String, dynamic>?) ?? {};
    return AuthApiModel(
      authId: (json['_id'] ?? json['id']) as String?,
      fullName: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      username: ((json['username'] ?? json['email'] ?? '') as String)
          .split('@')
          .first,
      role: (json['role'] ?? 'employee') as String,
      phoneNumber: json['phone'] as String?,
      profilePicture: json['profileImage'] as String?,
      notificationsEnabled: (notificationPreferences['orders'] ?? true) as bool,
      emailAlertsEnabled: (notificationPreferences['email'] ?? true) as bool,
    );
  }

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

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
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
