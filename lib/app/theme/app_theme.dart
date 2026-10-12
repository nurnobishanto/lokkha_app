import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/localization/app_localizations.dart';
import 'app_colors.dart';

export 'app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Font Sizing & Typography Tokens
/// ─────────────────────────────────────────────────────────────────────────────
class MyFonts {
  static TextStyle get getAppFontType =>
      LocalizationService.supportedLanguagesFontsFamilies[
          MySharedPref.getCurrentLocal().languageCode] ??
      const TextStyle();

  static TextStyle get headlineTextStyle => getAppFontType;
  static TextStyle get bodyTextStyle => getAppFontType;
  static TextStyle get buttonTextStyle => getAppFontType;
  static TextStyle get appBarTextStyle => getAppFontType;
  static TextStyle get chipTextStyle => getAppFontType;

  // Font sizes
  static double get appBarTittleSize => 18.sp;
  static double get body1TextSize => 13.sp;
  static double get body2TextSize => 13.sp;
  static double get headline1TextSize => 32.sp;
  static double get headline2TextSize => 24.sp;
  static double get headline3TextSize => 19.sp;
  static double get headline4TextSize => 16.sp;
  static double get headline5TextSize => 13.sp;
  static double get headline6TextSize => 11.sp;
  static double get buttonTextSize => 16.sp;
  static double get captionTextSize => 13.sp;
  static double get chipTextSize => 10.sp;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Central Semantic Text Styles
/// ─────────────────────────────────────────────────────────────────────────────
class AppTextStyles {
  static TextStyle get heading1 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline1TextSize,
        fontWeight: FontWeight.bold,
        color: Get.textTheme.displayLarge?.color,
      );

  static TextStyle get heading2 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline2TextSize,
        fontWeight: FontWeight.bold,
        color: Get.textTheme.displayMedium?.color,
      );

  static TextStyle get heading3 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline3TextSize,
        fontWeight: FontWeight.w700,
        color: Get.textTheme.displaySmall?.color,
      );

  static TextStyle get heading4 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline4TextSize,
        fontWeight: FontWeight.w600,
        color: Get.textTheme.headlineMedium?.color,
      );

  static TextStyle get heading5 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline5TextSize,
        fontWeight: FontWeight.w600,
        color: Get.textTheme.headlineSmall?.color,
      );

  static TextStyle get heading6 => MyFonts.headlineTextStyle.copyWith(
        fontSize: MyFonts.headline6TextSize,
        fontWeight: FontWeight.w500,
        color: Get.textTheme.titleLarge?.color,
      );

  static TextStyle get body1 => MyFonts.bodyTextStyle.copyWith(
        fontSize: MyFonts.body1TextSize,
        fontWeight: FontWeight.normal,
        color: Get.textTheme.bodyLarge?.color,
      );

  static TextStyle get body2 => MyFonts.bodyTextStyle.copyWith(
        fontSize: MyFonts.body2TextSize,
        fontWeight: FontWeight.normal,
        color: Get.textTheme.bodyMedium?.color,
      );

  static TextStyle get caption => MyFonts.bodyTextStyle.copyWith(
        fontSize: MyFonts.captionTextSize,
        fontWeight: FontWeight.w400,
        color: Get.textTheme.bodySmall?.color,
      );

  static TextStyle get button => MyFonts.buttonTextStyle.copyWith(
        fontSize: MyFonts.buttonTextSize,
        fontWeight: FontWeight.w600,
        color: Get.textTheme.labelLarge?.color,
      );

  static TextStyle get chip => MyFonts.chipTextStyle.copyWith(
        fontSize: MyFonts.chipTextSize,
        fontWeight: FontWeight.w500,
        color: Get.textTheme.bodySmall?.color,
      );

  static TextStyle get appBar => MyFonts.appBarTextStyle.copyWith(
        fontSize: MyFonts.appBarTittleSize,
        fontWeight: FontWeight.bold,
        color: Get.textTheme.titleLarge?.color,
      );

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
      color: color ?? Get.textTheme.bodyMedium?.color,
      decoration: decoration,
      letterSpacing: letterSpacing,
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Component Styles Factory
/// ─────────────────────────────────────────────────────────────────────────────
class MyStyles {
  static IconThemeData getIconTheme({required bool isLightTheme}) =>
      IconThemeData(
        color: isLightTheme
            ? LightThemeColors.iconColor
            : DarkThemeColors.iconColor,
      );

  static AppBarTheme getAppBarTheme({required bool isLightTheme}) =>
      AppBarTheme(
        elevation: 0,
        titleTextStyle:
            getTextTheme(isLightTheme: isLightTheme).bodyLarge!.copyWith(
                  color: Colors.white,
                  fontSize: MyFonts.appBarTittleSize,
                ),
        iconTheme: IconThemeData(
            color: isLightTheme
                ? LightThemeColors.appBarIconsColor
                : DarkThemeColors.appBarIconsColor),
        backgroundColor: isLightTheme
            ? LightThemeColors.appBarColor
            : DarkThemeColors.appbarColor,
      );

  static TextTheme getTextTheme({required bool isLightTheme}) => TextTheme(
        labelLarge:
            MyFonts.buttonTextStyle.copyWith(fontSize: MyFonts.buttonTextSize),
        bodyLarge: (MyFonts.bodyTextStyle).copyWith(
          fontWeight: FontWeight.bold,
          fontSize: MyFonts.body1TextSize,
          color: isLightTheme
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor,
        ),
        bodyMedium: (MyFonts.bodyTextStyle).copyWith(
            fontSize: MyFonts.body2TextSize,
            color: isLightTheme
                ? LightThemeColors.bodyTextColor
                : DarkThemeColors.bodyTextColor),
        displayLarge: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline1TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        displayMedium: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline2TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        displaySmall: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline3TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        headlineMedium: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.headline4TextSize,
          fontWeight: FontWeight.bold,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),
        headlineSmall: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline5TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        titleLarge: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline6TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        bodySmall: TextStyle(
          color: isLightTheme
              ? LightThemeColors.captionTextColor
              : DarkThemeColors.captionTextColor,
          fontSize: MyFonts.captionTextSize,
        ),
      );

  static ChipThemeData getChipTheme({required bool isLightTheme}) {
    return ChipThemeData(
      backgroundColor: isLightTheme
          ? LightThemeColors.chipBackground
          : DarkThemeColors.chipBackground,
      brightness: Brightness.light,
      labelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      secondaryLabelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      selectedColor: Colors.black,
      disabledColor: Colors.green,
      padding: const EdgeInsets.all(5),
      secondarySelectedColor: Colors.purple,
    );
  }

  static TextStyle getChipTextStyle({required bool isLightTheme}) {
    return MyFonts.chipTextStyle.copyWith(
      fontSize: MyFonts.chipTextSize,
      color: isLightTheme
          ? LightThemeColors.chipTextColor
          : DarkThemeColors.chipTextColor,
    );
  }

  static WidgetStateProperty<TextStyle?>? getElevatedButtonTextStyle(
      bool isLightTheme,
      {bool isBold = true,
      double? fontSize}) {
    return WidgetStateProperty.resolveWith<TextStyle>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return MyFonts.buttonTextStyle.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize ?? MyFonts.buttonTextSize,
              color: isLightTheme
                  ? LightThemeColors.buttonTextColor
                  : DarkThemeColors.buttonTextColor);
        } else if (states.contains(WidgetState.disabled)) {
          return MyFonts.buttonTextStyle.copyWith(
              fontSize: fontSize ?? MyFonts.buttonTextSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isLightTheme
                  ? LightThemeColors.buttonDisabledTextColor
                  : DarkThemeColors.buttonDisabledTextColor);
        }
        return MyFonts.buttonTextStyle.copyWith(
            fontSize: fontSize ?? MyFonts.buttonTextSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isLightTheme
                ? LightThemeColors.buttonTextColor
                : DarkThemeColors.buttonTextColor);
      },
    );
  }

  static ElevatedButtonThemeData getElevatedButtonTheme(
          {required bool isLightTheme}) =>
      ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(vertical: 8.h)),
          textStyle: getElevatedButtonTextStyle(isLightTheme),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return isLightTheme
                    ? LightThemeColors.buttonColor.withValues(alpha: 0.5)
                    : DarkThemeColors.buttonColor.withValues(alpha: 0.5);
              } else if (states.contains(WidgetState.disabled)) {
                return isLightTheme
                    ? LightThemeColors.buttonDisabledColor
                    : DarkThemeColors.buttonDisabledColor;
              }
              return isLightTheme
                  ? LightThemeColors.buttonColor
                  : DarkThemeColors.buttonColor;
            },
          ),
        ),
      );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Central AppTheme Definition
/// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get lightTheme => getThemeData(isLight: true);
  static ThemeData get darkTheme => getThemeData(isLight: false);

  static ThemeData getThemeData({required bool isLight}) {
    return ThemeData(
      useMaterial3: true,
      primaryColor: isLight
          ? LightThemeColors.primaryColor
          : DarkThemeColors.primaryColor,
      canvasColor:
          isLight ? LightThemeColors.accentColor : DarkThemeColors.accentColor,
      brightness: isLight ? Brightness.light : Brightness.dark,
      cardColor:
          isLight ? LightThemeColors.cardColor : DarkThemeColors.cardColor,
      hintColor: isLight
          ? LightThemeColors.hintTextColor
          : DarkThemeColors.hintTextColor,
      dividerColor: isLight
          ? LightThemeColors.dividerColor
          : DarkThemeColors.dividerColor,
      scaffoldBackgroundColor: isLight
          ? LightThemeColors.scaffoldBackgroundColor
          : DarkThemeColors.scaffoldBackgroundColor,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isLight
            ? LightThemeColors.primaryColor
            : DarkThemeColors.primaryColor,
      ),
      appBarTheme: MyStyles.getAppBarTheme(isLightTheme: isLight),
      elevatedButtonTheme:
          MyStyles.getElevatedButtonTheme(isLightTheme: isLight),
      textTheme: MyStyles.getTextTheme(isLightTheme: isLight),
      chipTheme: MyStyles.getChipTheme(isLightTheme: isLight),
      iconTheme: MyStyles.getIconTheme(isLightTheme: isLight),
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
  }
}

/// Backward compatibility alias
typedef MyTheme = AppTheme;

/// ─────────────────────────────────────────────────────────────────────────────
/// ThemeController (Backward Compatibility for existing switchers)
/// ─────────────────────────────────────────────────────────────────────────────
class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
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
    Get.changeTheme(AppTheme.getThemeData(isLight: newIsLight));
    Get.changeThemeMode(mode);
  }

  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

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

/// ─────────────────────────────────────────────────────────────────────────────
/// Riverpod Theme Mode State Management
/// ─────────────────────────────────────────────────────────────────────────────
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
