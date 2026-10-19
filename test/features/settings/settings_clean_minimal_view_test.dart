import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/profile/data/models/device_session_model.dart';
import 'package:lokkha/features/settings/presentation/providers/settings_notifier.dart';
import 'package:lokkha/features/settings/presentation/views/settings_view.dart';
import 'package:lokkha/shared/models/user.dart';

void main() {
  setUp(() {
    isLoggedIn.value = true;
  });

  tearDown(() {
    isLoggedIn.value = false;
  });

  group('Settings Clean Minimal View Tests', () {
    testWidgets('1. Profile hero banner, notification tile, and privacy policy sections are removed',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockDevices = UserDevicesData(
        activeCount: 3,
        maxAllowed: 3,
        activeDevices: [
          DeviceSessionModel(
            id: 1,
            deviceName: 'MacBook / Mac',
            platform: 'macOS',
            platformCategory: 'windows',
            platformCategoryLabel: 'Windows / PC',
            isCurrent: false,
            ipAddress: '172.68.218.191',
            lastActiveAt: '2026-10-19 18:00',
          ),
          DeviceSessionModel(
            id: 2,
            deviceName: 'iPhone 17 Pro Max',
            platform: 'iOS',
            platformCategory: 'ios',
            platformCategoryLabel: 'Mobile App',
            isCurrent: true,
            ipAddress: '172.68.218.192',
            lastActiveAt: '2026-10-19 18:05',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(
              () => _FakeSettingsNotifier(
                SettingsState(
                  userDevices: mockDevices,
                  isLoadingDevices: false,
                  currentUser: User(name: "sadman", phone: "01749784700"),
                ),
              ),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => const MaterialApp(
              home: SettingsView(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Profile hero banner must be REMOVED
      expect(find.text("শিক্ষার্থী"), findsNothing);
      expect(find.text("sadman"), findsNothing);
      expect(find.text("এডিট"), findsNothing);

      // Notification tile must be REMOVED
      expect(find.text("নোটিফিকেশন"), findsNothing);
      expect(find.text("পরীক্ষা ও লাইভ ইভেন্টের নোটিফিকেশন দেখুন"), findsNothing);

      // Privacy policy & Support section must be REMOVED
      expect(find.text("সহায়তা ও নীতিমালা"), findsNothing);
      expect(find.text("গোপনীয়তা নীতি (Privacy Policy)"), findsNothing);
      expect(find.text("শর্তাবলী ও নীতিমালা"), findsNothing);

      // 1. Device and session module is present and clean
      expect(find.text("ডিভাইস ও সেশন"), findsOneWidget);
      expect(find.text("3 / 3 টি সক্রিয়"), findsOneWidget);
      expect(find.text("MacBook / Mac"), findsOneWidget);
      expect(find.text("iPhone 17 Pro Max"), findsOneWidget);
      expect(find.text("বর্তমান"), findsOneWidget);
      expect(find.text("বন্ধ করুন"), findsOneWidget);
      expect(find.text("অন্যান্য সব ডিভাইস থেকে লগ আউট করুন"), findsOneWidget);

      // 2. Security module is present
      expect(find.text("নিরাপত্তা ও পাসওয়ার্ড"), findsOneWidget);
      expect(find.text("পাসওয়ার্ড পরিবর্তন করুন"), findsOneWidget);

      // 3. Interface module is present (Dark Mode)
      expect(find.text("ইন্টারফেস ও সেটিংস"), findsOneWidget);
      expect(find.text("থিম ও ডার্ক মোড"), findsOneWidget);

      // 4. Account Action module is present
      expect(find.text("অ্যাকাউন্ট অ্যাকশন"), findsOneWidget);
      expect(find.text("অ্যাকাউন্ট ডিলিট রিকোয়েস্ট"), findsOneWidget);
      expect(find.text("লগ আউট"), findsOneWidget);

      // 5. App version footer is present
      expect(find.text("লক্ষা অ্যাপ v1.0.0 • সকল স্বত্ব সংরক্ষিত"), findsOneWidget);
    });
  });
}

class _FakeSettingsNotifier extends SettingsNotifier {
  final SettingsState fixedState;
  _FakeSettingsNotifier(this.fixedState);

  @override
  SettingsState build() {
    return fixedState;
  }

  @override
  Future<void> refreshSettings() async {}

  @override
  Future<void> fetchDevices() async {}
}
