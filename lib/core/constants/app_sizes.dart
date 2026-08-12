import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  // Spacing / Paddings
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 24.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconExtraLarge = 48.0;

  // Reusable SizedBox components for spacing
  static const SizedBox spaceXs = SizedBox(height: xs, width: xs);
  static const SizedBox spaceS = SizedBox(height: s, width: s);
  static const SizedBox spaceM = SizedBox(height: m, width: m);
  static const SizedBox spaceL = SizedBox(height: l, width: l);
  static const SizedBox spaceXl = SizedBox(height: xl, width: xl);
  static const SizedBox spaceXxl = SizedBox(height: xxl, width: xxl);
}
