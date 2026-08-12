import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFEDF7EE),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentGreen,
        surface: AppColors.white,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          headlineMedium: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          titleLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          titleMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          bodyLarge: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: AppColors.textMedium,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: AppColors.textMedium,
          ),
          bodySmall: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: AppColors.textLight,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
    );
  }
}
