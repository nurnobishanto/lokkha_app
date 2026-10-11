import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'my_theme.dart';

export 'app_colors.dart';
export 'light_theme_colors.dart';
export 'dark_theme_colors.dart';
export 'my_theme.dart';
export 'text_style.dart';
export 'my_fonts.dart';
export 'my_styles.dart';

class AppTheme {
  static ThemeData get lightTheme => MyTheme.getThemeData(isLight: true);
  static ThemeData get darkTheme => MyTheme.getThemeData(isLight: false);

  static ThemeData getThemeData({required bool isLight}) =>
      MyTheme.getThemeData(isLight: isLight);
}

/// Riverpod ThemeMode Notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final mode = MySharedPref.getThemeMode();
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'system') return ThemeMode.system;
    return ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final modeStr = mode == ThemeMode.dark
        ? 'dark'
        : (mode == ThemeMode.system ? 'system' : 'light');
    MySharedPref.setThemeMode(modeStr);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
