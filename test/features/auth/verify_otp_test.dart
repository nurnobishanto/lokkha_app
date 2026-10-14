import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/features/auth/data/models/auth_response_model.dart';
import 'package:lokkha/features/auth/presentation/verify_otp/views/verify_otp_view.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:pinput/pinput.dart';

class _TestLocaleNotifier extends LocaleNotifier {
  final Locale _initial;
  _TestLocaleNotifier(this._initial);

  @override
  Locale build() => _initial;
}

class _TestThemeModeNotifier extends ThemeModeNotifier {
  final ThemeMode _initial;
  _TestThemeModeNotifier(this._initial);

  @override
  ThemeMode build() => _initial;
}

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

  group('VerifyOtpView Widget Tests', () {
    testWidgets('VerifyOtpView renders cleanly with all components', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestableWidget(
          const VerifyOtpView(
            phoneNumber: '01712345678',
            type: 'Login',
            autoStartTimer: false,
            autoSendOtp: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check Back Button
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Check Header Icon Badge
      expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);

      // Check Title
      expect(find.text('ওটিপি যাচাইকরণ'), findsOneWidget);

      // Check Formatted Phone Number Pill
      expect(find.text('01712 345678'), findsOneWidget);
      expect(find.text('পরিবর্তন'), findsOneWidget);

      // Check Pinput
      expect(find.byType(Pinput), findsOneWidget);

      // Check Verify Button
      expect(find.byType(AuthActionButton), findsOneWidget);
      expect(find.text('যাচাই করুন'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('VerifyOtpView renders properly on Tablet / iPad without overflow', (tester) async {
      tester.view.physicalSize = const Size(820 * 2, 1180 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestableWidget(
          const VerifyOtpView(
            phoneNumber: '01712345678',
            type: 'Registration',
            autoStartTimer: false,
            autoSendOtp: false,
          ),
          surfaceSize: const Size(820, 1180),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(Pinput), findsOneWidget);
      expect(find.text('যাচাই করুন'), findsOneWidget);
    });

    testWidgets('VerifyOtpView renders in English when locale is en', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestableWidget(
          const VerifyOtpView(
            phoneNumber: '01712345678',
            type: 'Login',
            autoStartTimer: false,
            autoSendOtp: false,
          ),
          locale: const Locale('en', 'US'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('OTP Verification'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('VerifyOtpView adapts to Dark Mode cleanly without error', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestableWidget(
          const VerifyOtpView(
            phoneNumber: '01712345678',
            type: 'Login',
            autoStartTimer: false,
            autoSendOtp: false,
          ),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.byType(Pinput), findsOneWidget);
    });

    test('AuthResponseModel parses expiresIn 300 correctly from root and nested data', () {
      final jsonNested = {
        'success': true,
        'message': 'OTP sent successfully.',
        'data': {
          'phone': '01712345678',
          'expires_in': 300,
        },
      };
      final res1 = AuthResponseModel.fromJson(jsonNested);
      expect(res1.expiresIn, equals(300));

      final jsonRoot = {
        'status': true,
        'message': 'OTP sent.',
        'expires_in': 300,
      };
      final res2 = AuthResponseModel.fromJson(jsonRoot);
      expect(res2.expiresIn, equals(300));
    });

    testWidgets('VerifyOtpView displays 05:00 for 300 seconds initialExpiresIn and enables resend button when expired', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestableWidget(
          const VerifyOtpView(
            phoneNumber: '01712345678',
            type: 'Login',
            autoStartTimer: false,
            autoSendOtp: false,
            initialExpiresIn: 300,
          ),
        ),
      );
      await tester.pump();

      // Check that 300s is formatted as 05:00
      expect(find.text('পুনরায় কোড পাঠান (05:00)'), findsOneWidget);

      // Now test with 0 seconds (expired state)
      await tester.pumpWidget(
        buildTestableWidget(
          const VerifyOtpView(
            phoneNumber: '01712345678',
            type: 'Login',
            autoStartTimer: false,
            autoSendOtp: false,
            initialExpiresIn: 0,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('কোড পাননি? '), findsOneWidget);
      expect(find.text('পুনরায় কোড পাঠান'), findsOneWidget);
    });
  });
}
