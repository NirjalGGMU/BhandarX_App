import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String _definedBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  static String get serverUrl {
    if (_definedBaseUrl.isNotEmpty) {
      return _definedBaseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');
    }
    if (kIsWeb) {
      return 'http://localhost:5002';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5002';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'http://localhost:5002';
      default:
        return 'http://localhost:5002';
    }
  }

  static String get baseUrl => '$serverUrl/api/v1';

  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '$serverUrl/${path.startsWith('/') ? path.substring(1) : path}';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
