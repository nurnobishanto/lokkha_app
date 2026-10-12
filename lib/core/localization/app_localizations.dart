import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';

import 'l10n/app_localizations.dart';

export 'l10n/app_localizations.dart';

/// Extension on BuildContext for quick, type-safe localization access
extension LocalizationExtension on BuildContext {
  /// Typed AppLocalizations accessor: `context.locale.resetPassword`
  AppLocalizations get locale => AppLocalizations.of(this)!;

  /// Typed AppLocalizations accessor: `context.l10n.resetPassword`
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Shorthand alias: `context.tr.appName`
  AppLocalizations get tr => AppLocalizations.of(this)!;
}

/// Riverpod Notifier to manage active Locale reactively throughout the app
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => MySharedPref.getCurrentLocal();

  /// Supported locales
  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;

  /// Update language by code ('en', 'bn')
  Future<void> setLocale(String languageCode) async {
    final targetLocale = supportedLocales.firstWhere(
      (loc) => loc.languageCode == languageCode,
      orElse: () => const Locale('bn', 'BD'),
    );

    if (state != targetLocale) {
      state = targetLocale;
      await MySharedPref.setCurrentLanguage(languageCode);
      if (!Get.testMode) {
        Get.updateLocale(targetLocale);
      }
    }
  }

  /// Toggle between Bengali ('bn') and English ('en')
  Future<void> toggleLocale() async {
    final nextCode = state.languageCode == 'bn' ? 'en' : 'bn';
    await setLocale(nextCode);
  }

  /// Whether current locale is English
  bool get isEnglish => state.languageCode.toLowerCase() == 'en';

  /// Whether current locale is Bengali
  bool get isBengali => state.languageCode.toLowerCase() == 'bn';
}

/// Global Riverpod provider for active Locale
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Legacy compatibility bridge for existing code
class LocalizationService {
  LocalizationService._();

  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;

  static const Locale defaultLanguage = Locale('bn', 'BD');

  static final Map<String, Locale> supportedLanguages = {
    'en': const Locale('en', 'US'),
    'bn': const Locale('bn', 'BD'),
  };

  static final Map<String, TextStyle> supportedLanguagesFontsFamilies = {
    'en': const TextStyle(fontFamily: 'BalooDa2'),
    'bn': const TextStyle(fontFamily: 'BalooDa2'),
  };

  static bool isLanguageSupported(String languageCode) =>
      supportedLanguages.containsKey(languageCode);

  static Future<void> updateLanguage(String languageCode) async {
    if (!isLanguageSupported(languageCode)) return;
    await MySharedPref.setCurrentLanguage(languageCode);
    final target = supportedLanguages[languageCode] ?? defaultLanguage;
    if (!Get.testMode) {
      Get.updateLocale(target);
    }
  }

  static bool isItEnglish() =>
      MySharedPref.getCurrentLocal().languageCode.toLowerCase().contains('en');

  static Locale getCurrentLocal() => MySharedPref.getCurrentLocal();
}
