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

  @override
  String get authGatewayTagline => 'সঠিক পথে, স্বল্প সময়ে';

  @override
  String get authGatewaySubtitle =>
      'কোনো রেজিস্ট্রেশন এর প্রয়োজন নেই, সরাসরি লগইন করুন';

  @override
  String get enterPhoneNumber => 'আপনার ১১ সংখ্যার ফোন নম্বর লিখুন';

  @override
  String get proceed => 'এগিয়ে যান';

  @override
  String get or => 'অথবা';

  @override
  String get continueWithGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get termsAgreementNotice => 'লগ ইন করে, আপনি আমাদের সাথে সম্মত হন।\n';

  @override
  String get termsAndConditions => 'শর্তাবলী ও নীতিমালা';

  @override
  String get warningTitle => 'সতর্কতা';

  @override
  String get providePhoneNumber => 'অনুগ্রহ করে আপনার ফোন নম্বরটি লিখুন।';

  @override
  String get invalidPhoneNumber => '১১ সংখ্যার সঠিক ফোন নম্বর প্রদান করুন।';

  @override
  String get googleSignInComingSoon => 'গুগল সাইন-ইন সেবাটি খুব শীঘ্রই আসছে...';
}
