import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.xxx:5050/api', // ← CHANGE to your backend IP/port
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static final _storage = const FlutterSecureStorage();

  static Future<void> initInterceptors() async {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('→ REQUEST: ${options.method} ${options.path}'); // debug
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('← RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('✗ ERROR: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  static Dio get dio => _dio;

  // Helper to save token after login/register
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
    print('TOKEN SAVED: $token'); // ← You will see this in VS Code console!
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}