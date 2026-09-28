import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/data/local/my_shared_pref.dart';
import 'my_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();

  /// 3-State ThemeMode: system, light, dark
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  /// Reactive boolean for fast switch toggling
  final RxBool isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialThemeMode();
  }

  void _loadInitialThemeMode() {
    final savedMode = MySharedPref.getThemeMode();
    switch (savedMode) {
      case 'dark':
        themeMode.value = ThemeMode.dark;
        isDark.value = true;
        break;
      case 'system':
        themeMode.value = ThemeMode.system;
        isDark.value = Get.isPlatformDarkMode;
        break;
      case 'light':
      default:
        themeMode.value = ThemeMode.light;
        isDark.value = false;
        break;
    }
  }

  /// Change theme mode explicitly (System / Light / Dark)
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;

    String modeString = 'light';
    bool newIsLight = true;

    if (mode == ThemeMode.dark) {
      modeString = 'dark';
      newIsLight = false;
      isDark.value = true;
    } else if (mode == ThemeMode.light) {
      modeString = 'light';
      newIsLight = true;
      isDark.value = false;
    } else {
      modeString = 'system';
      final isSysDark = Get.isPlatformDarkMode;
      newIsLight = !isSysDark;
      isDark.value = isSysDark;
    }

    MySharedPref.setThemeMode(modeString);
    Get.changeTheme(MyTheme.getThemeData(isLight: newIsLight));
    Get.changeThemeMode(mode);
  }

  /// Quick toggle between Light and Dark
  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  /// Human readable title in Bengali
  String get currentThemeTitle {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return 'ডার্ক মোড';
      case ThemeMode.system:
        return 'সিস্টেম ডিফল্ট';
      case ThemeMode.light:
        return 'লাইট মোড';
    }
  }
}
