import 'package:flutter/material.dart';
import '../../app/data/local/my_shared_pref.dart';
import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';

/// Central Semantic Design Tokens
/// Automatically adapts colors based on BuildContext brightness or current app theme mode.
class AppColors {
  AppColors._();

  // ───── Core Brand Palette (Constant Across Themes) ─────
  static const Color primary = LightThemeColors.primaryColor; // #2A8D6F
  static const Color primaryDark = Color(0xFF1B6B50);
  static const Color primaryDeep = Color(0xFF064E3B);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // ───── Theme-Aware Checkers ─────
  static bool isDarkMode([BuildContext? context]) {
    if (context != null) {
      return Theme.of(context).brightness == Brightness.dark;
    }
    return !MySharedPref.getThemeIsLight();
  }

  // ───── Scaffolds & Surfaces ─────
  static Color scaffold(BuildContext context) =>
      isDarkMode(context) ? DarkThemeColors.scaffoldBackgroundColor : LightThemeColors.scaffoldBackgroundColor;

  static Color card(BuildContext context) =>
      isDarkMode(context) ? DarkThemeColors.cardColor : LightThemeColors.white;

  static Color surfaceMuted(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF161F30) : const Color(0xFFF8FAFC);

  static Color surfaceSubtle(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFFF1F5F9);

  // ───── Borders & Dividers ─────
  static Color border(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  static Color borderLight(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

  static Color divider(BuildContext context) =>
      isDarkMode(context) ? DarkThemeColors.dividerColor : const Color(0xFFE5E7EB);

  // ───── Typography ─────
  static Color textPrimary(BuildContext context) =>
      isDarkMode(context) ? DarkThemeColors.bodyTextColor : const Color(0xFF0F172A);

  static Color textSecondary(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

  static Color textMuted(BuildContext context) =>
      isDarkMode(context) ? DarkThemeColors.captionTextColor : const Color(0xFF64748B);

  static Color textLight(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // ───── Accents & Feedback (Semantic) ─────
  static Color primaryLight(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF1E293B) : LightThemeColors.softBg;

  static Color accent(BuildContext context) =>
      isDarkMode(context) ? DarkThemeColors.accentColor : LightThemeColors.accentColor;

  // Success (Green / Emerald)
  static Color success(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF10B981) : const Color(0xFF059669);

  static Color successLight(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFECFDF5);

  // Warning (Amber / Gold)
  static Color warning(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);

  static Color warningDark(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFFF59E0B) : const Color(0xFFD97706);

  static Color warningLight(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF451A03).withValues(alpha: 0.4) : const Color(0xFFFEF3C7);

  // Danger (Red / Rose)
  static Color danger(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFFF87171) : const Color(0xFFDC2626);

  static Color dangerLight(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF450A0A).withValues(alpha: 0.4) : const Color(0xFFFEF2F2);

  // Info (Sky / Blue)
  static Color info(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);

  static Color infoLight(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF082F49).withValues(alpha: 0.4) : const Color(0xFFE0F2FE);
}

/// Extension for fast, clean, boilerplate-free syntax:
/// Example: `context.cardColor`, `context.textPrimary`, `context.isDark`
extension BuildContextThemeTokens on BuildContext {
  // Theme inspection
  bool get isDark => AppColors.isDarkMode(this);
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Scaffolds & Surfaces
  Color get scaffoldColor => AppColors.scaffold(this);
  Color get scaffoldBg => AppColors.scaffold(this);
  Color get cardColor => AppColors.card(this);
  Color get surfaceColor => AppColors.card(this);
  Color get surfaceMuted => AppColors.surfaceMuted(this);
  Color get surfaceSubtle => AppColors.surfaceSubtle(this);
  Color get subtleSurfaceColor => AppColors.surfaceSubtle(this);

  // Borders & Dividers
  Color get borderColor => AppColors.border(this);
  Color get border => AppColors.border(this);
  Color get borderLight => AppColors.borderLight(this);
  Color get dividerColor => AppColors.divider(this);
  Color get divider => AppColors.divider(this);

  // Typography
  Color get textPrimary => AppColors.textPrimary(this);
  Color get textSecondary => AppColors.textSecondary(this);
  Color get textMuted => AppColors.textMuted(this);
  Color get textLight => AppColors.textLight(this);

  // Brand & Semantic
  Color get primaryColor => AppColors.primary;
  Color get primaryDark => AppColors.primaryDark;
  Color get primaryLight => AppColors.primaryLight(this);
  Color get accentColor => AppColors.accent(this);

  Color get successColor => AppColors.success(this);
  Color get successLight => AppColors.successLight(this);
  Color get warningColor => AppColors.warning(this);
  Color get warningDark => AppColors.warningDark(this);
  Color get warningLight => AppColors.warningLight(this);
  Color get dangerColor => AppColors.danger(this);
  Color get dangerLight => AppColors.dangerLight(this);
  Color get infoColor => AppColors.info(this);
  Color get infoLight => AppColors.infoLight(this);
}
