import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/theme/my_fonts.dart';

class AppTextStyles {
  /// ✅ Heading 1 - Use for main screen title (e.g. Dashboard Title, Home Title)
  static TextStyle get heading1 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline1TextSize,
        fontWeight: FontWeight.bold,
        color: Get.textTheme.displayLarge?.color,
      );

  /// ✅ Heading 2 - Use for major section titles inside screens
  static TextStyle get heading2 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline2TextSize,
        fontWeight: FontWeight.bold,
        color: Get.textTheme.displayMedium?.color,
      );

  /// ✅ Heading 3 - Use for card titles, list headers, drawer headings
  static TextStyle get heading3 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline3TextSize,
        fontWeight: FontWeight.w700,
        color: Get.textTheme.displaySmall?.color,
      );

  /// ✅ Heading 4 - Use for form field section labels or minor sections
  static TextStyle get heading4 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline4TextSize,
        fontWeight: FontWeight.w600,
        color: Get.textTheme.headlineMedium?.color,
      );

  /// ✅ Heading 5 - Use for alert titles, dialog titles, confirmation boxes
  static TextStyle get heading5 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline5TextSize,
        fontWeight: FontWeight.w600,
        color: Get.textTheme.headlineSmall?.color,
      );

  /// ✅ Heading 6 - Use for settings tile labels, small section headers
  static TextStyle get heading6 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline6TextSize,
        fontWeight: FontWeight.w500,
        color: Get.textTheme.titleLarge?.color,
      );

  /// ✅ Body 1 - Use for main body content, paragraph text
  static TextStyle get body1 => MyFonts.bodyTextStyle.copyWith(
        fontSize: MyFonts.body1TextSize,
        fontWeight: FontWeight.normal,
        color: Get.textTheme.bodyLarge?.color,
      );

  /// ✅ Body 2 - Use for secondary content, small descriptions
  static TextStyle get body2 => MyFonts.bodyTextStyle.copyWith(
        fontSize: MyFonts.body2TextSize,
        fontWeight: FontWeight.normal,
        color: Get.textTheme.bodyMedium?.color,
      );

  /// ✅ Caption - Use for footnotes, timestamps, tooltips, image credits
  static TextStyle get caption => MyFonts.bodyTextStyle.copyWith(
        fontSize: MyFonts.captionTextSize,
        fontWeight: FontWeight.w400,
        color: Get.textTheme.bodySmall?.color,
      );

  /// ✅ Button - Use for ElevatedButton, OutlinedButton, ActionButton
  static TextStyle get button => MyFonts.buttonTextStyle.copyWith(
        fontSize: MyFonts.buttonTextSize,
        fontWeight: FontWeight.w600,
        color: Get.textTheme.labelLarge?.color,
      );

  /// ✅ Chip - Use for ChoiceChip, FilterChip, Tags
  static TextStyle get chip => MyFonts.chipTextStyle.copyWith(
        fontSize: MyFonts.chipTextSize,
        fontWeight: FontWeight.w500,
        color: Get.textTheme.bodySmall?.color,
      );

  /// ✅ AppBar - Use for app bar title text
  static TextStyle get appBar => MyFonts.appBarTextStyle.copyWith(
        fontSize: MyFonts.appBarTittleSize,
        fontWeight: FontWeight.bold,
        color: Get.textTheme.titleLarge?.color,
      );

  /// ✅ Custom - Use for on-the-fly customization with optional parameters
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return MyFonts.bodyTextStyle.copyWith(
      fontSize: fontSize ?? MyFonts.body2TextSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Get.textTheme.bodyLarge?.color,
      decoration: decoration,
      letterSpacing: letterSpacing,
    );
  }
}
