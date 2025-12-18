// lib/themes/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';


class AppTheme {
static ThemeData lightTheme = ThemeData(
useMaterial3: true,
scaffoldBackgroundColor: AppColors.background,
colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
textTheme: AppTextTheme.textTheme,


appBarTheme: const AppBarTheme(
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
elevation: 0,
),


drawerTheme: const DrawerThemeData(
backgroundColor: AppColors.surface,
),


bottomNavigationBarTheme: const BottomNavigationBarThemeData(
backgroundColor: AppColors.primary,
selectedItemColor: Colors.white,
unselectedItemColor: Colors.white70,
),


elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
),
);
}