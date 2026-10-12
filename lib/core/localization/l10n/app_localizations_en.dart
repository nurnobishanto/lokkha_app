// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lokkha';

  @override
  String get hello => 'Hello!';

  @override
  String get loading => 'Loading...';

  @override
  String get changeTheme => 'Change Theme';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get noInternetConnection =>
      'No internet connection. Please check your network.';

  @override
  String get serverNotResponding =>
      'Server is not responding. Please try again later.';

  @override
  String get urlNotFound => 'Requested resource not found.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get sessionExpired => 'Your session has expired. Please login again.';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';
}
