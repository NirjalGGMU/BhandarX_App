import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
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

  const AuthEntity({
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

  AuthEntity copyWith({
    String? authId,
    String? fullName,
    String? email,
    String? username,
    String? password,
    String? role,
    String? phoneNumber,
    String? profilePicture,
    bool? notificationsEnabled,
    bool? emailAlertsEnabled,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailAlertsEnabled: emailAlertsEnabled ?? this.emailAlertsEnabled,
    );
  }

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    username,
    password,
    role,
    phoneNumber,
    profilePicture,
    notificationsEnabled,
    emailAlertsEnabled,
  ];
}
