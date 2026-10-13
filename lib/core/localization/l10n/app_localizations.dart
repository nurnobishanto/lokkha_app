import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Lokkha'**
  String get appName;

  /// Greeting text
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// Loading state label
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Label for changing application theme
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get changeTheme;

  /// Label for changing application language
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Error message when device has no internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get noInternetConnection;

  /// Error message when server timeouts or fails to respond
  ///
  /// In en, this message translates to:
  /// **'Server is not responding. Please try again later.'**
  String get serverNotResponding;

  /// Error message when 404 endpoint is accessed
  ///
  /// In en, this message translates to:
  /// **'Requested resource not found.'**
  String get urlNotFound;

  /// Generic 500 error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// Generic unexpected error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Message shown when authentication token expires
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please login again.'**
  String get sessionExpired;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button label
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Reset password label
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Forgot password label
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// Retry action label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel action label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm action label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// OK action label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Tagline on the authentication gateway screen
  ///
  /// In en, this message translates to:
  /// **'On the right path, in less time'**
  String get authGatewayTagline;

  /// Subtitle explaining direct login on the auth gateway screen
  ///
  /// In en, this message translates to:
  /// **'No registration required, directly log in'**
  String get authGatewaySubtitle;

  /// Hint text for the phone input field
  ///
  /// In en, this message translates to:
  /// **'Enter your 11-digit phone number'**
  String get enterPhoneNumber;

  /// Button to continue with phone authentication
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// Divider text separating phone and social login
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// Button label for Google OAuth sign-in
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Prefix text for legal terms agreement
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to our\n'**
  String get termsAgreementNotice;

  /// Link label for terms of service and privacy policy
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Title for validation alert dialogs/snackbars
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// Error message when phone field is empty
  ///
  /// In en, this message translates to:
  /// **'Please provide your phone number.'**
  String get providePhoneNumber;

  /// Error message when phone number is less than 11 digits
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid 11-digit phone number.'**
  String get invalidPhoneNumber;

  /// Notice when Google sign-in is pressed before backend integration
  ///
  /// In en, this message translates to:
  /// **'Google sign-in service is coming soon...'**
  String get googleSignInComingSoon;

  /// Header title on sign in screen
  ///
  /// In en, this message translates to:
  /// **'Log in with your phone number'**
  String get loginWithPhoneNumber;

  /// Hint text for password field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Link text to log in with OTP instead of password
  ///
  /// In en, this message translates to:
  /// **'Forgot password? Log in with OTP!'**
  String get forgotPasswordOrOtp;

  /// Button to change phone number
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changePhone;

  /// Validation error when password field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get providePassword;

  /// Message displayed when login succeeds
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// Message displayed when login fails
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
