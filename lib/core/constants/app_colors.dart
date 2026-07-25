import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Theme Colors
  static const Color primaryGreen = Color(0xFF2E6F40);
  static const Color accentGreen = Color(0xFF5CA368);
  static const Color lightGreen = Color(0xFFE8F2EA);
  static const Color backgroundGreen = Color(0xFFF1F6F2);

  // Card Gradient Colors
  static const List<Color> cropCardGradient = [
    Color(0xFF8DBF9E),
    Color(0xFF5A9E72),
  ];

  static const List<Color> fertilizerCardGradient = [
    Color(0xFFA5D6A7),
    Color(0xFF4CAF50),
  ];

  // Glassmorphism / Translucent Colors
  static const Color glassBackground = Color(0x33FFFFFF); // Translucent white
  static const Color glassBorder = Color(0x4DFFFFFF); // Slight white border
  static const Color cardShadow = Color(0x0F000000);

  // Text Colors
  static const Color textDark = Color(0xFF1E2D22);
  static const Color textMedium = Color(0xFF5C6B5F);
  static const Color textLight = Color(0xFF8B9B8E);
  static const Color textGreenLink = Color(0xFF2E7D32);

  // Generic
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color notificationDot = Colors.red;
}
