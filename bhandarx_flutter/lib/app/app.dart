//lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:bhandarx_flutter/app/themes/app_theme.dart';
// REMOVED: unused import for app_colors.dart
import 'package:bhandarx_flutter/features/splash/presentation/pages/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BhandarX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}