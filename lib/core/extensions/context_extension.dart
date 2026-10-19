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

  // ─── Typography / Text Styles ───
  TextTheme get textStyle => Theme.of(this).textTheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get heading1 => AppTextStyles.heading1.copyWith(color: textPrimary);
  TextStyle get heading2 => AppTextStyles.heading2.copyWith(color: textPrimary);
  TextStyle get heading3 => AppTextStyles.heading3.copyWith(color: textPrimary);
  TextStyle get heading4 => AppTextStyles.heading4.copyWith(color: textPrimary);
  TextStyle get body1 => AppTextStyles.body1.copyWith(color: textPrimary);
  TextStyle get body2 => AppTextStyles.body2.copyWith(color: textSecondary);

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
