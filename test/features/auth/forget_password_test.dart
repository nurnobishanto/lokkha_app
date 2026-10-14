import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/localization/l10n/app_localizations.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/auth/presentation/forget_password/widgets/password_reset_success_dialog.dart';

class _MockAuthRepository implements AuthRepository {
  String? lastPhone;
  String? lastOtp;
  String? lastPassword;
  String? lastPasswordConfirmation;
  String? lastSendOtpPhone;
  String? lastSendOtpType;

  bool shouldSucceed = true;
  String successMessage = 'Password reset successful.';

  @override
  Future<AuthResponseModel> forgetPassword({
    required String phone,
    required String otp,
    required String password,
    String? passwordConfirmation,
  }) async {
    lastPhone = phone;
    lastOtp = otp;
    lastPassword = password;
    lastPasswordConfirmation = passwordConfirmation;

    return AuthResponseModel(
      status: shouldSucceed,
      message: shouldSucceed ? successMessage : 'Reset failed',
    );
  }

  @override
  Future<AuthResponseModel> sendOtp(String phone, {String type = 'Login'}) async {
    lastSendOtpPhone = phone;
    lastSendOtpType = type;
    return AuthResponseModel(
      status: shouldSucceed,
      message: shouldSucceed ? 'OTP sent successfully' : 'OTP failed',
      expiresIn: 300,
    );
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    lastPhone = phone;
    lastOtp = otp;
    return AuthResponseModel(
      status: shouldSucceed,
      message: shouldSucceed ? 'OTP verified' : 'Invalid OTP',
    );
  }

  @override
  Future<AuthResponseModel> checkPhone(String phone) async =>
      AuthResponseModel(status: true, isRegistered: true);

  @override
  Future<AuthResponseModel?> getCurrentUser() async => null;

  @override
  Future<AuthResponseModel> login({
    required String phone,
    String? type,
    String? password,
    String? otp,
    String? deviceName,
    String? platform,
  }) async =>
      AuthResponseModel(status: true);

  @override
  Future<bool> logout() async => true;

  @override
  Future<AuthResponseModel> register({
    required String phone,
    required String otp,
    String? referralCode,
    String? deviceName,
  }) async =>
      AuthResponseModel(status: true);
}

void main() {
  Widget buildTestableWidget(
    Widget child, {
    Locale locale = const Locale('bn', 'BD'),
    ThemeMode themeMode = ThemeMode.light,
    AuthRepository? authRepository,
  }) {
    return ProviderScope(
      overrides: [
        if (authRepository != null)
          authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          locale: locale,
          themeMode: themeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    );
  }

  group('Forget Password Clean Architecture & Domain Tests', () {
    test('ForgetPasswordUseCase delegates correctly to repository', () async {
      final mockRepo = _MockAuthRepository();
      final useCase = ForgetPasswordUseCase(mockRepo);

      final result = await useCase(
        phone: '01712345678',
        otp: '123456',
        password: 'newPassword123',
        passwordConfirmation: 'newPassword123',
      );

      expect(result.status, isTrue);
      expect(mockRepo.lastPhone, '01712345678');
      expect(mockRepo.lastOtp, '123456');
      expect(mockRepo.lastPassword, 'newPassword123');
      expect(mockRepo.lastPasswordConfirmation, 'newPassword123');
    });

    test('ResetPasswordState validation logic', () {
      const state1 = ResetPasswordState(
        password: 'pass',
        confirmPassword: 'pass',
      );
      // < 6 chars is invalid
      expect(state1.isValid, isFalse);
      expect(state1.doPasswordsMatch, isTrue);

      const state2 = ResetPasswordState(
        password: 'password123',
        confirmPassword: 'differentPassword',
      );
      // Mismatched passwords
      expect(state2.isValid, isFalse);
      expect(state2.doPasswordsMatch, isFalse);

      const state3 = ResetPasswordState(
        password: 'password123',
        confirmPassword: 'password123',
      );
      // Valid >= 6 and matching
      expect(state3.isValid, isTrue);
      expect(state3.doPasswordsMatch, isTrue);
    });
  });

  group('ForgetPasswordView Widget Tests', () {
    testWidgets('Renders header, phone field, and send otp action', (tester) async {
      final mockRepo = _MockAuthRepository();
      await tester.pumpWidget(
        buildTestableWidget(
          const ForgetPasswordView(initialPhoneNumber: '01712345678'),
          authRepository: mockRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('পাসওয়ার্ড ভুলে গেছেন?'), findsOneWidget);
      expect(find.text('ওটিপি পাঠান'), findsOneWidget);
      expect(find.text('01712345678'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders localized in English', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ForgetPasswordView(initialPhoneNumber: '01712345678'),
          locale: const Locale('en', 'US'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tapping back button in ForgetPasswordView executes safely', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ForgetPasswordView(initialPhoneNumber: '01712345678'),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('ResetPasswordView Widget Tests', () {
    testWidgets('Renders fields and validates password mismatch in real-time',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ResetPasswordView(
            phoneNumber: '01712345678',
            otp: '123456',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('নতুন পাসওয়ার্ড তৈরি করুন'), findsOneWidget);
      expect(find.text('পাসওয়ার্ড আপডেট করুন'), findsOneWidget);

      // Enter mismatched passwords
      final passwordFields = find.byType(TextField);
      expect(passwordFields, findsNWidgets(2));

      await tester.enterText(passwordFields.at(0), 'passwordA');
      await tester.enterText(passwordFields.at(1), 'passwordB');
      await tester.pumpAndSettle();

      expect(find.text('পাসওয়ার্ড দুটি মিলছে না'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tapping back button does not crash and executes smoothly',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ResetPasswordView(
            phoneNumber: '01712345678',
            otp: '123456',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('PasswordResetSuccessDialog Widget Tests', () {
    testWidgets('Renders congratulations title and Go to Login button', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PasswordResetSuccessDialog(phoneNumber: '01712345678'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('অভিনন্দন!'), findsOneWidget);
      expect(find.text('লগইন করুন'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
