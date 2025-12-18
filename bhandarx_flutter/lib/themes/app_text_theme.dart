// lib/themes/app_text_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTextTheme {
static TextTheme textTheme = GoogleFonts.interTextTheme(
const TextTheme(
headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
bodyLarge: TextStyle(fontSize: 16),
bodyMedium: TextStyle(fontSize: 14),
labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
),
);
}