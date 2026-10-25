import 'package:flutter/material.dart';
import 'package:lokkha/app/theme/app_theme.dart';

export 'package:go_router/go_router.dart';
export 'package:lokkha/core/localization/app_localizations.dart';

extension ContextExtension on BuildContext {
  // ─── Theme & Colors ───
  ThemeData get theme => Theme.of(this);
  bool get isDark => AppColors.isDarkMode(this);

  ColorScheme get color => Theme.of(this).colorScheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ─── Typography / Text Styles (Centralized via Theme & AppFontConfig) ───
  TextTheme get textStyle => Theme.of(this).textTheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Display / Hero Headings
  TextStyle get heading1 =>
      (textTheme.displayLarge ?? AppTextStyles.heading1).copyWith(color: textPrimary);
  TextStyle get h1 => heading1;

  TextStyle get heading2 =>
      (textTheme.displayMedium ?? AppTextStyles.heading2).copyWith(color: textPrimary);
  TextStyle get h2 => heading2;

  TextStyle get heading3 =>
      (textTheme.displaySmall ?? AppTextStyles.heading3).copyWith(color: textPrimary);
  TextStyle get h3 => heading3;

  /// Section Header Style (16.5.sp bold)
  TextStyle get heading4 =>
      (textTheme.headlineMedium ?? AppTextStyles.heading4).copyWith(color: textPrimary);
  TextStyle get h4 => heading4;
  TextStyle get sectionTitle => heading4;

  /// Sub-header / Prominent Title (15.sp semi-bold)
  TextStyle get heading5 =>
      (textTheme.headlineSmall ?? AppTextStyles.heading5).copyWith(color: textPrimary);
  TextStyle get h5 => heading5;

  /// Medium List/Card Title (14.5.sp semi-bold)
  TextStyle get titleMediumStyle =>
      (textTheme.titleMedium ?? AppTextStyles.heading5).copyWith(color: textPrimary);

  /// Compact Grid/Card Title (13.5.sp semi-bold)
  TextStyle get heading6 =>
      (textTheme.titleSmall ?? AppTextStyles.heading6).copyWith(color: textPrimary);
  TextStyle get h6 => heading6;
  TextStyle get cardTitle => heading6;

  /// AppBar Title Style (18.sp bold)
  TextStyle get appBarTitle =>
      (textTheme.titleLarge ?? AppTextStyles.appBar).copyWith(color: Colors.white);

  /// Primary Body / MCQ Question Text (14.5.sp medium)
  TextStyle get body1 =>
      (textTheme.bodyLarge ?? AppTextStyles.body1).copyWith(color: textPrimary);
  TextStyle get bodyLargeStyle => body1;

  /// Standard Body / MCQ Option / Subtitle Text (13.5.sp regular)
  TextStyle get body2 =>
      (textTheme.bodyMedium ?? AppTextStyles.body2).copyWith(color: textSecondary);
  TextStyle get bodyPrimary =>
      (textTheme.bodyMedium ?? AppTextStyles.body2).copyWith(color: textPrimary);

  /// Caption / Helper / Timestamp Text (12.sp regular)
  TextStyle get caption =>
      (textTheme.bodySmall ?? AppTextStyles.caption).copyWith(color: textSecondary);
  TextStyle get bodySmallStyle => caption;

  /// Button Text (15.sp semi-bold)
  TextStyle get buttonText =>
      (textTheme.labelLarge ?? AppTextStyles.button).copyWith(color: Colors.white);

  /// Chip / Tab / Action Pill Text (12.5.sp semi-bold)
  TextStyle get chipText =>
      (textTheme.labelMedium ?? AppTextStyles.chip).copyWith(color: textPrimary);

  /// Small Badge / Tag Text (10.sp bold)
  TextStyle get badgeText =>
      (textTheme.labelSmall ?? AppTextStyles.chip).copyWith(
        fontSize: AppFontConfig.badge,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  // ─── Scaffolds & Surfaces ───
  Color get scaffoldColor => AppColors.scaffold(this);
  Color get scaffoldBg => AppColors.scaffold(this);
  Color get cardColor => AppColors.card(this);
  Color get surfaceColor => AppColors.card(this);
  Color get surfaceMuted => AppColors.surfaceMuted(this);
  Color get surfaceSubtle => AppColors.surfaceSubtle(this);
  Color get subtleSurfaceColor => AppColors.surfaceSubtle(this);

  // ─── Borders & Dividers ───
  Color get borderColor => AppColors.border(this);
  Color get border => AppColors.border(this);
  Color get borderLight => AppColors.borderLight(this);
  Color get dividerColor => AppColors.divider(this);
  Color get divider => AppColors.divider(this);

  // ─── Text Colors ───
  Color get textPrimary => AppColors.textPrimary(this);
  Color get textSecondary => AppColors.textSecondary(this);
  Color get textMuted => AppColors.textMuted(this);
  Color get textLight => AppColors.textLight(this);

  // ─── Brand & Semantic Colors ───
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

  // ─── Screen Dimensions & Media Query ───
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
  bool get isLandscape => orientation == Orientation.landscape;

  // ─── Device & Focus Controls ───
  void hideKeyboard() => FocusScope.of(this).unfocus();

  // ─── Navigation Helper ───
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop<T>(result);

  // ─── SnackBar Helper ───
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
        ),
      );
  }
}
