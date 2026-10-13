import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/features/auth/presentation/auth_gateway/views/auth_gateway_view.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_divider.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_phone_field.dart';

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

  group('Auth Reusable Widgets Tests', () {
    testWidgets('AuthActionButton primary renders text and triggers callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: AuthActionButton.primary(
              text: 'এগিয়ে যান',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('এগিয়ে যান'), findsOneWidget);
      await tester.tap(find.text('এগিয়ে যান'));
      expect(tapped, isTrue);
    });

    testWidgets('AuthActionButton secondary (Google) renders text and triggers callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: AuthActionButton.secondary(
              text: 'Google দিয়ে চালিয়ে যান',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Google দিয়ে চালিয়ে যান'), findsOneWidget);
      await tester.tap(find.text('Google দিয়ে চালিয়ে যান'));
      expect(tapped, isTrue);
    });

    testWidgets('AuthDivider renders default and custom text', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(
            body: Column(
              children: [
                AuthDivider(),
                AuthDivider(text: 'OR'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('অথবা'), findsOneWidget);
      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('AuthPhoneField accepts input and limits to 11 digits', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: AuthPhoneField(controller: controller),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      await tester.enterText(textFieldFinder, '0171234567899');
      // Should limit to 11 digits
      expect(controller.text, '01712345678');
    });

    testWidgets('AuthGatewayView renders phone field and buttons on standard phone without overflow', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(const AuthGatewayView()));
      await tester.pumpAndSettle();

      expect(find.text('সঠিক পথে, স্বল্প সময়ে'), findsOneWidget);
      expect(find.byType(AuthPhoneField), findsOneWidget);
      expect(find.text('এগিয়ে যান'), findsOneWidget);
      expect(find.text('Google দিয়ে চালিয়ে যান'), findsOneWidget);
      expect(find.text('অথবা'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AuthGatewayView renders on iPad / Tablet screen without overflow', (tester) async {
      // iPad Air: 820 x 1180
      tester.view.physicalSize = const Size(820 * 2, 1180 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(
        const AuthGatewayView(),
        surfaceSize: const Size(820, 1180),
      ));
      await tester.pumpAndSettle();

      expect(find.text('সঠিক পথে, স্বল্প সময়ে'), findsOneWidget);
      expect(find.byType(AuthPhoneField), findsOneWidget);
      expect(find.text('এগিয়ে যান'), findsOneWidget);
      expect(find.text('Google দিয়ে চালিয়ে যান'), findsOneWidget);
      expect(find.text('অথবা'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AuthGatewayView renders localized in English when locale is en', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AuthGatewayView(),
        locale: const Locale('en', 'US'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('On the right path, in less time'), findsOneWidget);
      expect(find.text('Proceed'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Or'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AuthGatewayView adapts to Dark Mode cleanly without error', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AuthGatewayView(),
        themeMode: ThemeMode.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.text('সঠিক পথে, স্বল্প সময়ে'), findsOneWidget);
      expect(find.byType(AuthPhoneField), findsOneWidget);
      expect(find.text('এগিয়ে যান'), findsOneWidget);
      expect(tester.takeException(), isNull);
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
