import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';

void main() {
  group('BengaliNumberExtension & StringExtension Tests', () {
    test('toBnDigits converts English digits to Bengali numerals', () {
      expect('12345'.toBnDigits(), '১২৩৪৫');
      expect(2026.toBnDigits(), '২০২৬');
      expect('Batch 09, Room 402'.toBnDigits(), 'Batch ০৯, Room ৪০২');
      expect((null as String?).toBnDigits(), '');
    });

    test('toEnDigits converts Bengali digits to English digits', () {
      expect('১২৩৪৫'.toEnDigits(), '12345');
      expect('২০২৬-১০-১৯'.toEnDigits(), '2026-10-19');
      expect((null as String?).toEnDigits(), '');
    });

    test('isValidBdMobile validates Bangladeshi mobile numbers correctly', () {
      expect('01712345678'.isValidBdMobile, isTrue);
      expect('01812345678'.isValidBdMobile, isTrue);
      expect('01912345678'.isValidBdMobile, isTrue);
      expect('01312345678'.isValidBdMobile, isTrue);
      expect('01512345678'.isValidBdMobile, isTrue);

      // Invalid operators or length
      expect('01112345678'.isValidBdMobile, isFalse); // Citycell retired
      expect('01212345678'.isValidBdMobile, isFalse);
      expect('12345'.isValidBdMobile, isFalse);
      expect((null as String?).isValidBdMobile, isFalse);
    });

    test('stripHtml strips tags and entities properly', () {
      expect('<p>Hello <b>World</b></p>'.stripHtml, 'Hello World');
      expect('&nbsp;<span>Special</span>'.stripHtml, 'Special');
    });

    test('capitalizeFirst capitalizes first character', () {
      expect('flutter'.capitalizeFirst, 'Flutter');
      expect(''.capitalizeFirst, '');
      expect((null as String?).capitalizeFirst, '');
    });
  });

  group('AppEmptyStateWidget & AppErrorStateWidget Tests', () {
    testWidgets('AppEmptyStateWidget renders title, subtitle and action',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: AppEmptyStateWidget(
                title: 'কোন কোর্স নেই',
                subtitle: 'নতুন কোর্স দেখতে পরে আসুন',
                actionText: 'রিফ্রেশ',
                onAction: () => actionTriggered = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('কোন কোর্স নেই'), findsOneWidget);
      expect(find.text('নতুন কোর্স দেখতে পরে আসুন'), findsOneWidget);
      expect(find.text('রিফ্রেশ'), findsOneWidget);

      await tester.tap(find.text('রিফ্রেশ'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });

    testWidgets('AppErrorStateWidget renders message and triggers retry',
        (tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: AppErrorStateWidget(
                message: 'সার্ভার পাওয়া যায়নি',
                onRetry: () => retryTriggered = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('সার্ভার পাওয়া যায়নি'), findsOneWidget);
      expect(find.text('আবার চেষ্টা করুন'), findsOneWidget);

      await tester.tap(find.text('আবার চেষ্টা করুন'));
      await tester.pump();
      expect(retryTriggered, isTrue);
    });
  });
}
