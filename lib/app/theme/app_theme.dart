import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/theme/my_theme.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';

export 'package:lokkha/core/theme/app_colors.dart';
export 'package:lokkha/core/theme/light_theme_colors.dart';
export 'package:lokkha/core/theme/dark_theme_colors.dart';
export 'package:lokkha/core/theme/my_theme.dart';
export 'package:lokkha/core/theme/text_style.dart';

class AppTheme {
  static ThemeData get lightTheme => MyTheme.getThemeData(isLight: true);
  static ThemeData get darkTheme => MyTheme.getThemeData(isLight: false);
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
