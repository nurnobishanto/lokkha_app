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
  String get resetPassword => 'Reset Password';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get authGatewayTagline => 'On the right path, in less time';

  @override
  String get authGatewaySubtitle => 'No registration required, directly log in';

  @override
  String get enterPhoneNumber => 'Enter your 11-digit phone number';

  @override
  String get proceed => 'Proceed';

  @override
  String get or => 'Or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get termsAgreementNotice => 'By logging in, you agree to our\n';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get warningTitle => 'Warning';

  @override
  String get providePhoneNumber => 'Please provide your phone number.';

  @override
  String get invalidPhoneNumber =>
      'Please provide a valid 11-digit phone number.';

  @override
  String get googleSignInComingSoon =>
      'Google sign-in service is coming soon...';

  @override
  String get loginWithPhoneNumber => 'Log in with your phone number';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get forgotPasswordOrOtp => 'Forgot password? Log in with OTP!';

  @override
  String get changePhone => 'Change';

  @override
  String get providePassword => 'Please enter your password.';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get otpSubtitle => 'We\'ve sent a 6-digit verification code to';

  @override
  String get resendOtp => 'Resend Code';

  @override
  String resendCodeIn(String seconds) {
    return 'Resend code in ($seconds)';
  }

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code? ';

  @override
  String get verify => 'Verify';

  @override
  String get otpRequired => 'Please enter the 6-digit verification code.';

  @override
  String get codeResentSuccess => 'Verification code resent successfully.';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your phone number to receive the verification code.';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String get createNewPasswordSubtitle =>
      'Use at least 8 characters with numbers and symbols.';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords don\'t match';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordResetSuccessTitle => 'Congratulations !';

  @override
  String get passwordResetSuccessMessage =>
      'Password Reset successful. You can now sign in with your new password';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get sendOtpAction => 'Send OTP';

  @override
  String get loginWithOtp => 'Log in with OTP';
}
