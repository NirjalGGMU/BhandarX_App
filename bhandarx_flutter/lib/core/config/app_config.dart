// lib/core/config/app_config.dart
class AppConfig {
  // IMPORTANT: Choose the right URL based on where you're testing:

  // For Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:5050';

  // for iOS Simulator or Web:
  static const String baseUrl = 'http://localhost:5050/api/auth';

  // For Physical Device (replace with your computer's IP):
  // Find your IP: Run 'ipconfig' on Windows, look for IPv4 Address
  // static const String baseUrl = 'http://192.168.1.100:5050';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}