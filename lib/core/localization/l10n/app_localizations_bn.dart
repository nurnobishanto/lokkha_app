// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'লক্ষ্য';

  @override
  String get hello => 'হ্যালো!';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get changeTheme => 'থিম পরিবর্তন করুন';

  @override
  String get changeLanguage => 'ভাষা পরিবর্তন করুন';

  @override
  String get noInternetConnection =>
      'কোনো ইন্টারনেট সংযোগ নেই। আপনার নেটওয়ার্ক চেক করুন।';

  @override
  String get serverNotResponding =>
      'সার্ভার সাড়া দিচ্ছে না। অনুগ্রহ করে কিছুক্ষণ পর চেষ্টা করুন।';

  @override
  String get urlNotFound => 'অনুরোধকৃত রিসোর্স পাওয়া যায়নি।';

  @override
  String get serverError => 'সার্ভার এরর। অনুগ্রহ করে কিছুক্ষণ পর চেষ্টা করুন।';

  @override
  String get somethingWentWrong =>
      'কিছু ভুল হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get sessionExpired =>
      'আপনার সেশনের মেয়াদ শেষ হয়ে গেছে। অনুগ্রহ করে পুনরায় লগইন করুন।';

  @override
  String get login => 'লগইন';

  @override
  String get register => 'রেজিস্টার';

  @override
  String get logout => 'লগআউট';

  @override
  String get resetPassword => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get ok => 'ঠিক আছে';
}
