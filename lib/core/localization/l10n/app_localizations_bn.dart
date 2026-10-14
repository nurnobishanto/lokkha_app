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

  @override
  String get loginWithPhoneNumber => 'আপনার ফোন নম্বর দিয়ে লগইন করুন';

  @override
  String get enterPassword => 'আপনার পাসওয়ার্ড লিখুন';

  @override
  String get forgotPasswordOrOtp => 'পাসওয়ার্ড মনে নেই? OTP দিয়ে লগইন করুন!';

  @override
  String get changePhone => 'পরিবর্তন';

  @override
  String get providePassword => 'অনুগ্রহ করে আপনার পাসওয়ার্ড লিখুন।';

  @override
  String get loginSuccess => 'লগইন সফল হয়েছে!';

  @override
  String get loginFailed => 'লগইন ব্যর্থ হয়েছে। দয়া করে আবার চেষ্টা করুন।';

  @override
  String get otpVerification => 'ওটিপি যাচাইকরণ';

  @override
  String get otpSubtitle => 'আপনার নম্বরে ৬-সংখ্যার যাচাইকরণ কোড পাঠানো হয়েছে';

  @override
  String get resendOtp => 'পুনরায় কোড পাঠান';

  @override
  String resendCodeIn(String seconds) {
    return 'পুনরায় কোড পাঠান ($seconds)';
  }

  @override
  String get didNotReceiveCode => 'কোড পাননি? ';

  @override
  String get verify => 'যাচাই করুন';

  @override
  String get otpRequired => 'অনুগ্রহ করে ৬-সংখ্যার ওটিপি কোডটি লিখুন।';

  @override
  String get codeResentSuccess => 'যাচাইকরণ কোড সফলভাবে পাঠানো হয়েছে।';

  @override
  String get forgotPasswordSubtitle =>
      'ভেরিফিকেশন কোড পেতে আপনার ফোন নম্বর লিখুন';

  @override
  String get createNewPassword => 'নতুন পাসওয়ার্ড তৈরি করুন';

  @override
  String get createNewPasswordSubtitle =>
      'কমপক্ষে ৮ অক্ষরের একটি শক্তিশালী পাসওয়ার্ড তৈরি করুন';

  @override
  String get newPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get confirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get passwordsDoNotMatch => 'পাসওয়ার্ড দুটি মিলছে না';

  @override
  String get updatePassword => 'পাসওয়ার্ড আপডেট করুন';

  @override
  String get passwordResetSuccessTitle => 'অভিনন্দন!';

  @override
  String get passwordResetSuccessMessage =>
      'আপনার পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে। এখন নতুন পাসওয়ার্ড দিয়ে লগইন করুন।';

  @override
  String get goToLogin => 'লগইন করুন';

  @override
  String get sendOtpAction => 'ওটিপি পাঠান';

  @override
  String get loginWithOtp => 'OTP দিয়ে লগইন';
}
