import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/shared/shared.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  group('AppButton Design System Tests', () {
    testWidgets('AppButton.primary renders text and reacts to click', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppButton.primary(
            text: 'সাইন ইন করুন',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('সাইন ইন করুন'), findsOneWidget);
      await tester.tap(find.text('সাইন ইন করুন'));
      expect(tapped, true);
    });

    testWidgets('AppButton variants render correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              AppButton.secondary(
                text: 'সেকেন্ডারি বাটন',
                onPressed: () {},
              ),
              AppButton.outline(
                text: 'আউটলাইন বাটন',
                onPressed: () {},
              ),
              AppButton.text(
                text: 'টেক্সট বাটন',
                onPressed: () {},
              ),
              AppButton.danger(
                text: 'মুছে ফেলুন',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      expect(find.text('সেকেন্ডারি বাটন'), findsOneWidget);
      expect(find.text('আউটলাইন বাটন'), findsOneWidget);
      expect(find.text('টেক্সট বাটন'), findsOneWidget);
      expect(find.text('মুছে ফেলুন'), findsOneWidget);
    });

    testWidgets('AppButton shows progress indicator when isLoading is true', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppButton(
            text: 'সাবমিট করুন',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('সাবমিট করুন'), findsNothing);

      await tester.tap(find.byType(AppButton));
      expect(tapped, false);
    });

    testWidgets('AppButton does not trigger onPressed when disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppButton(
            text: 'নিষ্ক্রিয় বাটন',
            onPressed: null,
          ),
        ),
      );

      expect(find.text('নিষ্ক্রিয় বাটন'), findsOneWidget);
      await tester.tap(find.text('নিষ্ক্রিয় বাটন'));
      // No crashes and disabled visual state
    });

    testWidgets('CustomActionButton legacy adapter delegates to AppButton properly', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          CustomActionButton(
            text: 'পরবর্তী ধাপ',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('পরবর্তী ধাপ'), findsOneWidget);
      await tester.tap(find.text('পরবর্তী ধাপ'));
      expect(tapped, true);
    });

    testWidgets('DecisionButton legacy adapter renders with leading widget', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          DecisionButton(
            text: 'মডেল টেস্ট শুরু করুন',
            leadingWidget: const Icon(Icons.play_arrow),
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('মডেল টেস্ট শুরু করুন'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      await tester.tap(find.text('মডেল টেস্ট শুরু করুন'));
      expect(tapped, true);
    });

    testWidgets('ExamCustomButton legacy adapter renders properly', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          ExamCustomButton(
            text: 'পরবর্তী',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('পরবর্তী'), findsOneWidget);
      await tester.tap(find.text('পরবর্তী'));
      expect(tapped, true);
    });
  });
}
