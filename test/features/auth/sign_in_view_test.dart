import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/device_utils.dart';
import 'package:lokkha/features/auth/auth.dart';

void main() {
  Widget buildTestableWidget(
    Widget child, {
    Size surfaceSize = const Size(390, 844),
    Locale locale = const Locale('bn', 'BD'),
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return ProviderScope(
      overrides: [
        localeProvider.overrideWith(() => _TestLocaleNotifier(locale)),
        themeModeProvider.overrideWith(() => _TestThemeModeNotifier(themeMode)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          themeMode: themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: child,
        ),
      ),
    );
  }

  group('SignInView & AuthPasswordField Widget Tests', () {
    testWidgets('AuthPasswordField toggles password visibility', (tester) async {
      final controller = TextEditingController(text: 'secret123');
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: AuthPasswordField(controller: controller),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      // Tap visibility toggle icon
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      final updatedTextField = tester.widget<TextField>(find.byType(TextField));
      expect(updatedTextField.obscureText, isFalse);
    });

    testWidgets('SignInView renders phone badge, password field, and submit button without overflow', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(
          const SignInView(phoneNumber: '01712345678'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('01712345678'), findsOneWidget);
      expect(find.text('আপনার ফোন নম্বর দিয়ে লগইন করুন'), findsOneWidget);
      expect(find.byType(AuthPasswordField), findsOneWidget);
      expect(find.text('পাসওয়ার্ড ভুলে গেছেন?'), findsOneWidget);
      expect(find.text('OTP দিয়ে লগইন'), findsOneWidget);
      expect(find.text('এগিয়ে যান'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SignInView renders on iPad / Tablet screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(820 * 2, 1180 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(
          const SignInView(phoneNumber: '01712345678'),
          surfaceSize: const Size(820, 1180),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('01712345678'), findsOneWidget);
      expect(find.byType(AuthPasswordField), findsOneWidget);
      expect(find.text('এগিয়ে যান'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SignInView renders localized in English when locale is en', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SignInView(phoneNumber: '01712345678'),
          locale: const Locale('en', 'US'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Log in with your phone number'), findsOneWidget);
      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.text('Log in with OTP'), findsOneWidget);
      expect(find.text('Proceed'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SignInView adapts to Dark Mode cleanly without error', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SignInView(phoneNumber: '01712345678'),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('01712345678'), findsOneWidget);
      expect(find.byType(AuthPasswordField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('V1 Auth Login Architecture & Model Tests', () {
    test('AuthResponseModel correctly parses V1 Login 200 OK response', () {
      final jsonResponse = {
        "success": true,
        "message": "Login successful.",
        "data": {
          "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_token",
          "token_type": "bearer",
          "profile_completed": true,
          "user": {
            "id": 42,
            "user_id": "260900042",
            "name": "Arif Ahmed",
            "phone": "01712345678",
            "email": "arif@gmail.com",
            "photo_url": "https://lokkha.com/uploads/profile/user_66ed.jpg",
            "reward_points": 140,
            "is_subscribed": true,
            "active_package": {
              "id": 12,
              "package_name": "BCS & Bank Combo 6 Months",
              "expires_at": "2026-12-31 23:59:59",
              "days_left": 101,
              "is_trial": false
            }
          }
        }
      };

      final authModel = AuthResponseModel.fromJson(jsonResponse);

      expect(authModel.status, isTrue);
      expect(authModel.message, equals('Login successful.'));
      expect(authModel.token, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_token'));
      expect(authModel.tokenType, equals('bearer'));
      expect(authModel.profileCompleted, isTrue);
      expect(authModel.user, isNotNull);
      expect(authModel.user?.id, equals(42));
      expect(authModel.user?.userId, equals('260900042'));
      expect(authModel.user?.name, equals('Arif Ahmed'));
      expect(authModel.user?.phone, equals('01712345678'));
      expect(authModel.user?.email, equals('arif@gmail.com'));
      expect(authModel.user?.photoUrl, equals('https://lokkha.com/uploads/profile/user_66ed.jpg'));
      expect(authModel.user?.rewardPoints, equals(140));
      expect(authModel.user?.isSubscribed, isTrue);
      expect(authModel.user?.activePackage?['package_name'], equals('BCS & Bank Combo 6 Months'));
    });

    test('DeviceUtils returns fallback platform and mockable device name safely', () async {
      DeviceUtils.setMockDeviceName('Google Pixel 8');
      final deviceName = await DeviceUtils.getDeviceName();
      expect(deviceName, equals('Google Pixel 8'));

      final platform = DeviceUtils.getPlatform();
      expect(platform, isNotEmpty);
      DeviceUtils.reset();
    });

    test('LoginUseCase calls repository with type, value, and phone', () async {
      final mockRepo = _MockAuthRepository();
      final useCase = LoginUseCase(mockRepo);

      final result = await useCase(
        phone: '01712345678',
        type: 'password',
        password: 'secret123',
      );

      expect(result.status, isTrue);
      expect(mockRepo.lastLoginPhone, equals('01712345678'));
      expect(mockRepo.lastLoginType, equals('password'));
      expect(mockRepo.lastLoginPassword, equals('secret123'));
    });
  });
}

class _TestLocaleNotifier extends LocaleNotifier {
  final Locale initialLocale;
  _TestLocaleNotifier(this.initialLocale);

  @override
  Locale build() => initialLocale;
}

class _TestThemeModeNotifier extends ThemeModeNotifier {
  final ThemeMode initialMode;
  _TestThemeModeNotifier(this.initialMode);

  @override
  ThemeMode build() => initialMode;
}

class _MockAuthRepository implements AuthRepository {
  String? lastLoginPhone;
  String? lastLoginType;
  String? lastLoginPassword;
  String? lastLoginOtp;
  String? lastLoginDeviceName;
  String? lastLoginPlatform;

  @override
  Future<AuthResponseModel> login({
    required String phone,
    String? type,
    String? password,
    String? otp,
    String? deviceName,
    String? platform,
  }) async {
    lastLoginPhone = phone;
    lastLoginType = type;
    lastLoginPassword = password;
    lastLoginOtp = otp;
    lastLoginDeviceName = deviceName;
    lastLoginPlatform = platform;
    return AuthResponseModel(
      status: true,
      token: 'mock_jwt_token',
      message: 'Login successful.',
    );
  }

  @override
  Future<AuthResponseModel> checkPhone(String phone) async =>
      AuthResponseModel(status: true, isRegistered: true);

  @override
  Future<AuthResponseModel?> getCurrentUser() async => null;

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

  @override
  Future<AuthResponseModel> sendOtp(String phone, {String type = 'Login'}) async =>
      AuthResponseModel(status: true);

  @override
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  }) async =>
      AuthResponseModel(status: true);

  @override
  Future<AuthResponseModel> forgetPassword({
    required String phone,
    required String otp,
    required String password,
    String? passwordConfirmation,
  }) async =>
      AuthResponseModel(status: true, message: 'Password reset successful');
}
