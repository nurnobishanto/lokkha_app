import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/profile/presentation/profile_update/riverpod/profile_update_notifier.dart';
import 'package:lokkha/features/profile/presentation/profile_update/views/profile_update_view.dart';
import 'package:lokkha/shared/models/user.dart';

class _FakeProfileUpdateNotifier extends ProfileUpdateNotifier {
  final ProfileUpdateState initialState;
  _FakeProfileUpdateNotifier([this.initialState = const ProfileUpdateState()]);

  @override
  ProfileUpdateState build() => initialState;
}

void main() {
  setUp(() {
    isLoggedIn.value = true;
    myUser = User(
      id: 1,
      name: 'Sadman Sakib',
      email: 'sadman@example.com',
      phone: '01749784788',
      gender: 'male',
      dateOfBirth: '2000-01-01',
      occupation: 'Student',
      organization: 'Dhaka University',
    );
  });

  tearDown(() {
    isLoggedIn.value = false;
  });

  group('ProfileUpdateView UI & UX Tests', () {
    testWidgets('1. All modules, fields, gender chips, and update button render properly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileUpdateNotifierProvider.overrideWith(
              () => _FakeProfileUpdateNotifier(
                const ProfileUpdateState(
                  gender: 'পুরুষ',
                  dob: '2000-01-01',
                ),
              ),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => const MaterialApp(
              home: ProfileUpdateView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // AppBar
      expect(find.text('প্রোফাইল আপডেট করুন'), findsOneWidget);

      // Identity Header
      expect(find.text('01749784788'), findsOneWidget);
      expect(find.text('ছবি পরিবর্তন'), findsOneWidget);

      // Personal Information Module
      expect(find.text('ব্যক্তিগত তথ্য'), findsOneWidget);
      expect(find.text('পূর্ণ নাম'), findsOneWidget);
      expect(find.text('Sadman Sakib'), findsOneWidget);
      expect(find.text('ইমেইল ঠিকানা'), findsOneWidget);
      expect(find.text('sadman@example.com'), findsOneWidget);
      expect(find.text('জন্ম তারিখ'), findsOneWidget);
      expect(find.text('2000-01-01'), findsOneWidget);

      // 1-Tap Gender Chips
      expect(find.text('লিঙ্গ'), findsOneWidget);
      expect(find.text('পুরুষ'), findsOneWidget);
      expect(find.text('মহিলা'), findsOneWidget);
      expect(find.text('অন্যান্য'), findsOneWidget);

      // Academic and Work Module
      expect(find.text('পেশা ও শিক্ষা প্রতিষ্ঠান'), findsOneWidget);
      expect(find.text('পেশা'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('প্রতিষ্ঠান'), findsOneWidget);
      expect(find.text('Dhaka University'), findsOneWidget);

      // Password Accordion (Initially Collapsed for minimal clean UX)
      expect(find.text('পাসওয়ার্ড পরিবর্তন'), findsOneWidget);
      expect(find.text('ঐচ্ছিক'), findsOneWidget);
      expect(find.text('পরিবর্তন করতে চাইলে ট্যাপ করুন'), findsOneWidget);
      expect(find.text('বর্তমান পাসওয়ার্ড'), findsNothing);

      // Update Action Button
      expect(find.text('আপডেট সংরক্ষণ করুন'), findsOneWidget);
    });

    testWidgets('2. Password accordion expands on tap and displays current, new, and confirm password fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileUpdateNotifierProvider.overrideWith(
              () => _FakeProfileUpdateNotifier(),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => const MaterialApp(
              home: ProfileUpdateView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially collapsed
      expect(find.text('বর্তমান পাসওয়ার্ড'), findsNothing);

      // Scroll down to reveal password accordion
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap on password accordion
      await tester.tap(find.text('পাসওয়ার্ড পরিবর্তন'));
      await tester.pumpAndSettle();

      // Now expanded
      expect(find.text('বর্তমান পাসওয়ার্ড'), findsOneWidget);
      expect(find.text('নতুন পাসওয়ার্ড'), findsOneWidget);
      expect(find.text('পাসওয়ার্ড নিশ্চিত করুন'), findsOneWidget);
      expect(find.text('পরিবর্তন করতে না চাইলে বন্ধ করুন'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.text('পাসওয়ার্ড পরিবর্তন'));
      await tester.pumpAndSettle();
      expect(find.text('বর্তমান পাসওয়ার্ড'), findsNothing);
    });

    testWidgets('3. Gender chips can be switched with 1-tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => const MaterialApp(
              home: ProfileUpdateView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'মহিলা'
      await tester.tap(find.text('মহিলা'));
      await tester.pumpAndSettle();

      // Tap 'অন্যান্য'
      await tester.tap(find.text('অন্যান্য'));
      await tester.pumpAndSettle();

      // Verify the widget didn't crash and is responsive
      expect(find.text('অন্যান্য'), findsOneWidget);
    });
  });
}
