import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme lightTextTheme =
      GoogleFonts.notoSansDevanagariTextTheme().copyWith(
    headlineLarge: GoogleFonts.notoSansDevanagari(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.notoSansDevanagari(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.notoSansDevanagari(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.notoSansDevanagari(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.notoSansDevanagari(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
    labelLarge: GoogleFonts.notoSansDevanagari(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  );

  static TextTheme darkTextTheme =
      GoogleFonts.notoSansDevanagariTextTheme().copyWith(
    headlineLarge: GoogleFonts.notoSansDevanagari(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: AppColors.darkTextPrimary,
    ),
    headlineMedium: GoogleFonts.notoSansDevanagari(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.darkTextPrimary,
    ),
    titleLarge: GoogleFonts.notoSansDevanagari(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.darkTextPrimary,
    ),
    bodyLarge: GoogleFonts.notoSansDevanagari(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
    ),
    bodyMedium: GoogleFonts.notoSansDevanagari(
      fontSize: 14,
      color: AppColors.darkTextSecondary,
    ),
    labelLarge: GoogleFonts.notoSansDevanagari(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  );
}
