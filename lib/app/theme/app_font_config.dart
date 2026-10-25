import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Central Font & Typography Configuration (`AppFontConfig`)
/// ─────────────────────────────────────────────────────────────────────────────
/// Single source of truth for all font sizes and line heights across the app.
/// Change any base value or [scaleFactor] here to update typography globally.
class AppFontConfig {
  AppFontConfig._();

  /// Primary Font Family across the app
  static const String fontFamily = 'BalooDa2';

  /// Global multiplier for all central typography tokens.
  /// - 1.00 = Standard Senior Production Scale
  /// - 1.05 = 5% larger across all tokens
  /// - 1.10 = 10% larger across all tokens
  static const double scaleFactor = 1.0;

  /// Global MediaQuery TextScaler factor
  static const double textScaleFactor = 1.0;

  // ─── Standard Production Base Sizes (375x812 viewport) ─────────────────────
  static const double _displayLarge = 26.0; // h1
  static const double _displayMedium = 22.0; // h2
  static const double _displaySmall = 18.5; // h3
  static const double _headlineMedium = 16.5; // h4 / Section Header
  static const double _headlineSmall = 15.0; // h5 / Sub-header
  static const double _titleLarge = 18.0; // AppBar Title
  static const double _titleMedium = 14.5; // List/Card Primary Title
  static const double _titleSmall = 13.5; // Grid/Compact Card Title
  static const double _bodyLarge = 14.5; // Primary Body / MCQ Question
  static const double _bodyMedium = 13.5; // Standard Body / MCQ Option
  static const double _bodySmall = 12.0; // Caption / Subtitle / Meta
  static const double _labelLarge = 15.0; // Button Text
  static const double _labelMedium = 12.5; // Chip / Tab / See All
  static const double _labelSmall = 10.0; // Badge / Tag (PRO, LIVE)

  // ─── Responsive Scaled Getters (`.sp`) ─────────────────────────────────────
  static double get h1 => (_displayLarge * scaleFactor).sp;
  static double get h2 => (_displayMedium * scaleFactor).sp;
  static double get h3 => (_displaySmall * scaleFactor).sp;
  static double get h4 => (_headlineMedium * scaleFactor).sp;
  static double get h5 => (_headlineSmall * scaleFactor).sp;
  static double get h6 => (_titleSmall * scaleFactor).sp;

  static double get appBarTitle => (_titleLarge * scaleFactor).sp;
  static double get sectionTitle => (_headlineMedium * scaleFactor).sp;
  static double get titleMedium => (_titleMedium * scaleFactor).sp;
  static double get cardTitle => (_titleSmall * scaleFactor).sp;

  static double get body1 => (_bodyLarge * scaleFactor).sp;
  static double get body2 => (_bodyMedium * scaleFactor).sp;
  static double get caption => (_bodySmall * scaleFactor).sp;

  static double get button => (_labelLarge * scaleFactor).sp;
  static double get chip => (_labelMedium * scaleFactor).sp;
  static double get badge => (_labelSmall * scaleFactor).sp;
}
