
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_styles.dart';


class MyTheme {
  static ThemeData getThemeData({required bool isLight}) {
    return ThemeData(
      // primarySwatch: Colors.green,

      useMaterial3: true,
      // main color
      primaryColor: isLight
          ? LightThemeColors.primaryColor
          : DarkThemeColors.primaryColor,
      // secondary color
      canvasColor:
          isLight ? LightThemeColors.accentColor : DarkThemeColors.accentColor,
      // color contrast (if the theme is dark text should be white for example)
      brightness: isLight ? Brightness.light : Brightness.dark,
      // card widget background color
      cardColor:
          isLight ? LightThemeColors.cardColor : DarkThemeColors.cardColor,
      // hint text color
      hintColor: isLight
          ? LightThemeColors.hintTextColor
          : DarkThemeColors.hintTextColor,
      // divider color
      dividerColor: isLight
          ? LightThemeColors.dividerColor
          : DarkThemeColors.dividerColor,
      scaffoldBackgroundColor: isLight
          ? LightThemeColors.scaffoldBackgroundColor
          : DarkThemeColors.scaffoldBackgroundColor,

      // progress bar theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isLight
            ? LightThemeColors.primaryColor
            : DarkThemeColors.primaryColor,
      ),

      // appBar theme
      appBarTheme: MyStyles.getAppBarTheme(isLightTheme: isLight),

      // elevated button theme
      elevatedButtonTheme:
          MyStyles.getElevatedButtonTheme(isLightTheme: isLight),

      // text theme
      textTheme: MyStyles.getTextTheme(isLightTheme: isLight),

      // chip theme
      chipTheme: MyStyles.getChipTheme(isLightTheme: isLight),

      // icon theme
      iconTheme: MyStyles.getIconTheme(isLightTheme: isLight),

      // Material 3 ColorScheme
      colorScheme: ColorScheme(
        brightness: isLight ? Brightness.light : Brightness.dark,
        primary: isLight ? LightThemeColors.primaryColor : DarkThemeColors.primaryColor,
        onPrimary: Colors.white,
        secondary: isLight ? LightThemeColors.accentColor : DarkThemeColors.accentColor,
        onSecondary: isLight ? Colors.black87 : Colors.white,
        error: isLight ? LightThemeColors.red : DarkThemeColors.red,
        onError: Colors.white,
        surface: isLight ? LightThemeColors.scaffoldBackgroundColor : DarkThemeColors.scaffoldBackgroundColor,
        onSurface: isLight ? LightThemeColors.bodyTextColor : DarkThemeColors.bodyTextColor,
        surfaceContainer: isLight ? Colors.white : DarkThemeColors.cardColor,
        outline: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
      ),

      // Component themes
      dialogTheme: DialogThemeData(
        backgroundColor: isLight ? Colors.white : DarkThemeColors.cardColor,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? Colors.white : DarkThemeColors.cardColor,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: isLight ? Colors.white : DarkThemeColors.cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static void changeTheme() {
    bool isLightTheme = MySharedPref.getThemeIsLight();
    bool newIsLight = !isLightTheme;
    MySharedPref.setThemeIsLight(newIsLight);
    Get.changeTheme(getThemeData(isLight: newIsLight));
    Get.changeThemeMode(newIsLight ? ThemeMode.light : ThemeMode.dark);
  }

  /// check if the theme is light or dark
  static bool get isDark => !MySharedPref.getThemeIsLight();
  bool get getThemeIsLight => MySharedPref.getThemeIsLight();
}
