// lib/features/auth/data/datasources/remote/auth_remote_datasource.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhandarx_flutter/core/api/api_client.dart';
import 'package:bhandarx_flutter/core/api/api_endpoints.dart';
import 'package:bhandarx_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:bhandarx_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/src/framework.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref);
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final Ref ref;
  late final Dio _dio = ref.read(apiClientProvider!).dio;
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = "bhandarx_jwt_token";

  AuthRemoteDatasource(this.ref);

  ProviderListenable<dynamic>? get apiClientProvider => null;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          "email": email,
          "password": password,
        },
      );

      final responseData = response.data;

      if (responseData['message'] == "Login successful") {
        final data = responseData['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final userMap = data['user'] as Map<String, dynamic>;

        // Save token
        await _storage.write(key: _tokenKey, value: token);
        debugPrint("TOKEN SAVED SUCCESSFULLY: $token"); // ← You will see this!

        // Return user model (adapt field names to your AuthApiModel)
        // Assuming your AuthApiModel has fields like id, name, email, role
        return AuthApiModel.fromJson({
          'authId': userMap['id'],
          'fullName': userMap['name'],
          'email': userMap['email'],
          'role': userMap['role'],
          // Add more if needed
        });
      }

      return null;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? "Login failed";
      debugPrint("Login error: $message");
      throw Exception(message);
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          "name": user.fullName, // Assuming fullName is in model
          "email": user.email,
          "password": user.password, // Assuming password is temporarily in model
          "confirmPassword": user.password,
        },
      );

      print(response.data);

      final responseData = response.data;

      if (responseData['message'] == "User registered successfully") {
        final registeredUser = responseData['data'] as Map<String, dynamic>;

        // Optional: Auto-login after register for better UX
        // Here, we return the registered user (no token yet, since backend doesn't return it on register)
        // You can auto-call login in viewmodel if needed
print(registeredUser);
        return AuthApiModel.fromJson({
          'authId': registeredUser['id'],
          // 'fullName': registeredUser['name'],
          'email': registeredUser['email'],
          'role': registeredUser['role'],
          // Add more if needed
        });
      }

      throw Exception("Registration failed");
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? "Registration failed";
      debugPrint("Register error: $message");
      throw Exception(message);
    }
  }

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    // Implement if needed, e.g., GET /users/$authId with token
    try {
      final response = await _dio.get("/users/$authId"); // Assume endpoint
      // Parse and return
      return AuthApiModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception("Failed to get user");
    }
  }
}

 // lib/features/auth/data/datasources/remote/auth_remote_datasource.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:bhandarx_flutter/core/api/api_client.dart';
// import 'package:bhandarx_flutter/core/api/api_endpoints.dart';
// import 'package:bhandarx_flutter/core/services/storage/user_session_service.dart';
// import 'package:bhandarx_flutter/features/auth/data/datasources/auth_datasource.dart';
// import 'package:bhandarx_flutter/features/auth/data/models/auth_api_model.dart';

// final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
//   final apiClient = ref.read(apiClientProvider);
//   final userSessionService = ref.read(userSessionServiceProvider);
//   return AuthRemoteDatasource(
//     apiClient: apiClient,
//     userSessionService: userSessionService,
//   );
// });

// class AuthRemoteDatasource implements IAuthRemoteDatasource {
//   final ApiClient _apiClient;
//   final UserSessionService _userSessionService;

//   AuthRemoteDatasource({
//     required ApiClient apiClient,
//     required UserSessionService userSessionService,
//   }) : _apiClient = apiClient,
//        _userSessionService = userSessionService;

//   @override
//   Future<AuthApiModel?> getUserById(String authId) {
//     // TODO: implement getUserById
//     throw UnimplementedError();
//   }

//   @override
//   Future<AuthApiModel?> login(String email, String password) async {
//     final response = await _apiClient.post(
//       ApiEndpoints.studentLogin,
//       data: {"email": email, "password": password},
//     );

//     if (response.data["success"] == true) {
//       final data = response.data["data"] as Map<String, dynamic>;
//       final user = AuthApiModel.fromJson(data);
//       // info: Save user session
//       await _userSessionService.saveUserSession(
//         userId: user.authId!,
//         email: user.email,
//         username: user.username,
//         fullName: user.fullName,
//         phoneNumber: user.phoneNumber, batchId: '',
//       );
//       return user;
//     }
//     return null;
//   }

//   @override
//   Future<AuthApiModel> register(AuthApiModel user) async {
//     final response = await _apiClient.post(
//       ApiEndpoints.students,
//       data: user.toJson(),
//     );

//     if (response.data["success"] == true) {
//       final data = response.data["data"] as Map<String, dynamic>;
//       final resistedUser = AuthApiModel.fromJson(data);
//       return resistedUser;
//     }

//     return user;
//   }
// }



// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:bhandarx_flutter/core/api/api_client.dart';
// import 'package:bhandarx_flutter/core/api/api_endpoints.dart';
// import 'package:bhandarx_flutter/core/services/storage/user_session_service.dart';
// import 'package:bhandarx_flutter/features/auth/data/datasources/auth_datasource.dart';
// import 'package:bhandarx_flutter/features/auth/data/models/auth_api_model.dart';

// final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
//   final apiClient = ref.read(apiClientProvider);
//   final userSessionService = ref.read(userSessionServiceProvider);
//   return AuthRemoteDatasource(
//     apiClient: apiClient,
//     userSessionService: userSessionService,
//   );
// });

// class AuthRemoteDatasource implements IAuthRemoteDatasource {
//   final ApiClient _apiClient;
//   final UserSessionService _userSessionService;

//   AuthRemoteDatasource({
//     required ApiClient apiClient,
//     required UserSessionService userSessionService,
//   }) : _apiClient = apiClient,
//        _userSessionService = userSessionService;

//   @override
//   Future<AuthApiModel?> getUserById(String authId) {
//     // TODO: implement getUserById
//     throw UnimplementedError();
//   }

//   @override
//   Future<AuthApiModel?> login(String email, String password) async {
//     final response = await _apiClient.post(
//       ApiEndpoints.studentLogin,
//       data: {"email": email, "password": password},
//     );

//     if (response.data["success"] == true) {
//       final data = response.data["data"] as Map<String, dynamic>;
//       final user = AuthApiModel.fromJson(data);
//       // info: Save user session
//       await _userSessionService.saveUserSession(
//         userId: user.authId!,
//         email: user.email,
//         username: user.username,
//         fullName: user.fullName,
//         phoneNumber: user.phoneNumber,
//       );
//       return user;
//     }
//     return null;
//   }

//   @override
//   Future<AuthApiModel> register(AuthApiModel user) async {
//     final response = await _apiClient.post(
//       ApiEndpoints.students,
//       data: user.toJson(),
//     );

//     if (response.data["success"] == true) {
//       final data = response.data["data"] as Map<String, dynamic>;
//       final resistedUser = AuthApiModel.fromJson(data);
//       return resistedUser;
//     }

//     return user;
//   }
// }