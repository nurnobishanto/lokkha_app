import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/profile/presentation/self_exam_history/riverpod/self_exam_history_notifier.dart';
import 'package:lokkha/features/profile/presentation/self_exam_history/views/self_exam_history_view.dart';
import 'package:lokkha/features/profile/presentation/self_exam_history/widgets/self_exam_card.dart';

void main() {
  group('SelfExamHistoryNotifier Tests', () {
    test('initializes cleanly without uninitialized provider error', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(selfExamHistoryNotifierProvider);
      expect(state.isLoading, false);
      expect(state.currentPage, 1);
      expect(state.examList.length, 4);
      expect(state.examList.first.id, '9560');
    });

    test('onPageChanged updates page and loads page items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(selfExamHistoryNotifierProvider.notifier);
      notifier.onPageChanged(2);

      final state2 = container.read(selfExamHistoryNotifierProvider);
      expect(state2.currentPage, 2);
      expect(state2.examList.length, 2);
      expect(state2.examList.first.id, '9556');
    });
  });

  group('SelfExamHistoryView Widget Tests', () {
    testWidgets('renders SelfExamHistoryView without ProviderException', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const ProviderScope(
            child: MaterialApp(
              home: SelfExamHistoryView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('আমার সেলফ টেস্ট'), findsOneWidget);
      expect(find.byType(SelfExamCard), findsWidgets);
      expect(find.textContaining('9560'), findsOneWidget);
    });
  });
}
