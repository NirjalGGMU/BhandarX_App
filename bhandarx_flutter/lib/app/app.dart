import 'package:flutter/material.dart';
// Change 'bhandarx_frontend' to 'bhandarx_flutter'
import 'package:bhandarx_flutter/app/themes/app_theme.dart';
import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/features/splash/presentation/pages/splash_screen.dart';

// import 'package:lost_n_found/app/theme/app_theme.dart';
// import 'package:lost_n_found/features/splash/presentation/pages/splash_screen.dart';  bhandarx_flutter/lib/features/splash/presentation/pages/splash_page.dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
