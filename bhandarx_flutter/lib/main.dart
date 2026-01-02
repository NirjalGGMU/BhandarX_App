// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'screens/splash_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/dashboard_screen.dart';

// void main() {
//   runApp(const BhandarXApp());
// }

// class BhandarXApp extends StatelessWidget {
//   const BhandarXApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BhandarX',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3949AB)),
//         textTheme: GoogleFonts.interTextTheme(),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF2196F3),
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//       ),
//       initialRoute: SplashScreen.routeName,
//       routes: {
//         SplashScreen.routeName: (_) => const SplashScreen(),
//         OnboardingScreen.routeName: (_) => const OnboardingScreen(),
//         LoginScreen.routeName: (_) => const LoginScreen(),
//         RegisterScreen.routeName: (_) => const RegisterScreen(),
//         DashboardScreen.routeName: (_) => const DashboardScreen(),
//       },
//     );
//   }
// }






// Latest code befor now

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'screens/splash_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/dashboard_screen.dart';

// void main() {
//   runApp(const BhandarXApp());
// }

// class BhandarXApp extends StatelessWidget {
//   const BhandarXApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BhandarX',
//       debugShowCheckedModeBanner: false,

//       theme: ThemeData(
//         useMaterial3: true,

//         // 🔹 BRAND COLORS (existing only)
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF3949AB),
//           primary: const Color(0xFF3949AB),
//           secondary: const Color(0xFF1E3A8A),
//           background: const Color(0xFFF8FAFC),
//         ),

//         // 🔹 GLOBAL FONT
//         textTheme: GoogleFonts.interTextTheme(),

//         // 🔹 SCAFFOLD THEME
//         scaffoldBackgroundColor: const Color(0xFFF8FAFC),

//         // 🔹 APP BAR THEME
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF1E3A8A),
//           foregroundColor: Colors.white,
//           elevation: 0,
//           centerTitle: true,
//         ),

//         // 🔹 ELEVATED BUTTON THEME (Login, Register, Onboarding)
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF3949AB),
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             textStyle: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),

//         // 🔹 INPUT FIELD THEME
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.grey.shade50,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide:
//                 const BorderSide(color: Color(0xFF3949AB), width: 2),
//           ),
//           labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),

//       // 🔹 ROUTES
//       initialRoute: SplashScreen.routeName,
//       routes: {
//         SplashScreen.routeName: (_) => const SplashScreen(),
//         OnboardingScreen.routeName: (_) => const OnboardingScreen(),
//         LoginScreen.routeName: (_) => const LoginScreen(),
//         RegisterScreen.routeName: (_) => const RegisterScreen(),
//         DashboardScreen.routeName: (_) => const DashboardScreen(),
//       },
//     );
//   }
// }



// bhandarx_flutter/lib/main.dart
// import 'package:flutter/material.dart';
// import 'themes/app_theme.dart';


// import 'screens/splash_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/dashboard_screen.dart';


// void main() {
// runApp(const BhandarXApp());
// }


// class BhandarXApp extends StatelessWidget {
// const BhandarXApp({super.key});


// @override
// Widget build(BuildContext context) {
// return MaterialApp(
// title: 'BhandarX',
// debugShowCheckedModeBanner: false,
// theme: AppTheme.lightTheme,
// initialRoute: SplashScreen.routeName,
// routes: {
// SplashScreen.routeName: (_) => const SplashScreen(),
// OnboardingScreen.routeName: (_) => const OnboardingScreen(),
// LoginScreen.routeName: (_) => const LoginScreen(),
// RegisterScreen.routeName: (_) => const RegisterScreen(),
// DashboardScreen.routeName: (_) => const DashboardScreen(),
// },
// );
// }
// }

// lib/main.dart
// lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'themes/app_theme.dart';
// import 'screens/splash_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/dashboard_screen.dart';

// void main() {
//   runApp(const BhandarXApp());
// }

// class BhandarXApp extends StatelessWidget {
//   const BhandarXApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BhandarX',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme.copyWith(
//         // Enhance the centralized theme with Google Fonts and fine-tuned styles
//         textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF3949AB), // Indigo shade – professional & modern
//           brightness: Brightness.light,
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF2196F3), // Blue – matches your original design
//           foregroundColor: Colors.white,
//           elevation: 0,
//           centerTitle: true,
//         ),
//         bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//       ),
//       initialRoute: SplashScreen.routeName,
//       routes: {
//         SplashScreen.routeName: (_) => const SplashScreen(),
//         OnboardingScreen.routeName: (_) => const OnboardingScreen(),
//         LoginScreen.routeName: (_) => const LoginScreen(),
//         RegisterScreen.routeName: (_) => const RegisterScreen(),
//         DashboardScreen.routeName: (_) => const DashboardScreen(),
//       },
//     );
//   }
// }



// lib/main.dart

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/themes/app_theme.dart';
import 'app/themes/app_colors.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';

void main() {
  runApp(const BhandarXApp());
}

class BhandarXApp extends StatelessWidget {
  const BhandarXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BhandarX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        DashboardScreen.routeName: (_) => const DashboardScreen(),
      },
    );
  }
}