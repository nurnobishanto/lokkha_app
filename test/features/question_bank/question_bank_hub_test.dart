import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/question_bank/presentation/providers/question_bank_hub_notifier.dart';
import 'package:lokkha/features/question_bank/presentation/views/question_bank_exam_view.dart';
import 'package:lokkha/features/question_bank/presentation/views/question_bank_view.dart';
import 'package:lokkha/features/question_bank/presentation/widgets/question_bank_exam_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, _) => MaterialApp(
          home: child,
        ),
      ),
    );
  }

  group('Question Bank Hub & Exam System Tests', () {
    test('QuestionBankHubNotifier filters banks and subjects correctly by search query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(questionBankHubNotifierProvider.notifier);
      final initialState = container.read(questionBankHubNotifierProvider);

      expect(initialState.popularBanks.length, greaterThanOrEqualTo(4));
      expect(initialState.subjectBanks.length, greaterThanOrEqualTo(13));

      // Filter by 'বিসিএস'
      notifier.setSearchQuery('বিসিএস');
      final filteredState = container.read(questionBankHubNotifierProvider);

      expect(filteredState.filteredPopularBanks.any((b) => b.title.contains('বিসিএস')), isTrue);
      expect(filteredState.filteredPopularBanks.any((b) => b.title.contains('ব্যাংক')), isFalse);

      // Filter by 'বাংলা'
      notifier.setSearchQuery('বাংলা');
      final banglaFiltered = container.read(questionBankHubNotifierProvider);
      expect(banglaFiltered.filteredSubjectBanks.any((s) => s.title.contains('বাংলা')), isTrue);
    });

    test('QuestionBankHubNotifier safely rebuilds multiple times without LateInitializationError', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger initial build
      expect(container.read(questionBankHubNotifierProvider).popularBanks.isNotEmpty, isTrue);

      // Invalidate and rebuild (simulates router push / pop / rebuild)
      container.invalidate(questionBankHubNotifierProvider);
      expect(container.read(questionBankHubNotifierProvider).popularBanks.isNotEmpty, isTrue);

      // Refresh again
      container.refresh(questionBankHubNotifierProvider);
      expect(container.read(questionBankHubNotifierProvider).popularBanks.isNotEmpty, isTrue);
    });

    testWidgets('QuestionBankView renders clean minimal UI with full titles', (tester) async {
      await tester.pumpWidget(createTestWidget(const QuestionBankView()));
      await tester.pumpAndSettle();

      expect(find.text('প্রশ্নব্যাংক হাব'), findsOneWidget);
      expect(find.text('প্রশ্নব্যাংক বা বিষয় খুঁজুন...'), findsOneWidget);
      expect(find.text('বুকমার্ক ও সেভ করা প্রশ্ন'), findsNothing);

      // Verify popular banks exist with full titles (no truncation)
      expect(find.text('বিসিএস প্রিলিমিনারি'), findsOneWidget);
      expect(find.text('শিক্ষক নিবন্ধন (NTRCA)'), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('প্রাথমিক সহকারী শিক্ষক নিয়োগ'),
        find.byType(ListView),
        const Offset(0, -50),
      );
      expect(find.text('প্রাথমিক সহকারী শিক্ষক নিয়োগ'), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('সমন্বিত ব্যাংক নিয়োগ পরীক্ষা'),
        find.byType(ListView),
        const Offset(0, -50),
      );
      expect(find.text('সমন্বিত ব্যাংক নিয়োগ পরীক্ষা'), findsOneWidget);

      // Action buttons
      expect(find.text('পরীক্ষা দিন'), findsWidgets);
      expect(find.text('প্রশ্ন সমাধান'), findsWidgets);

      // Drag to reveal subject banks
      await tester.dragUntilVisible(
        find.text('বাংলা'),
        find.byType(ListView),
        const Offset(0, -50),
      );
      expect(find.text('বাংলা'), findsOneWidget);
      expect(find.text('English Language'), findsOneWidget);
    });

    testWidgets('QuestionBankExamSheet displays exam modes and duration chips', (tester) async {
      final item = HomeQuestionBankItem(
        id: 2,
        title: 'বিসিএস প্রিলিমিনারি',
        subtitle: '১০ম থেকে ৪৬তম বিসিএস বিগত সকল পরীক্ষার ব্যাখ্যাসহ প্রশ্নব্যাংক',
        badge: '১০ম-৪৬তম',
        themeColor: 'emerald',
      );

      await tester.pumpWidget(
        createTestWidget(
          Scaffold(
            body: QuestionBankExamSheet(bankItem: item),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('বিসিএস প্রিলিমিনারি'), findsOneWidget);
      expect(find.text('১০ম-৪৬তম'), findsOneWidget);
      expect(find.text('লাইভ পরীক্ষা শুরু করুন'), findsOneWidget);
      expect(find.text('অনুশীলন মোড'), findsOneWidget);
      expect(find.text('বিগত প্রশ্নসমূহ'), findsOneWidget);
    });

    testWidgets('QuestionBankExamView handles option selection and exam submission', (tester) async {
      final item = HomeQuestionBankItem(
        id: 1,
        title: 'বাংলা ভাষা ও সাহিত্য',
        badge: 'বাংলা',
      );

      await tester.pumpWidget(
        createTestWidget(
          QuestionBankExamView(
            bankItem: item,
            durationMinutes: 10,
            isPracticeMode: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('বাংলা ভাষা ও সাহিত্য'), findsWidgets);
      expect(find.text('লাইভ পরীক্ষা'), findsOneWidget);
      expect(find.text('প্রশ্ন ১ / ২'), findsOneWidget);

      // Select an option
      await tester.tap(find.text('মাত্রাবৃত্ত ছন্দ'));
      await tester.pumpAndSettle();

      // Go to next question
      await tester.tap(find.text('পরবর্তী'));
      await tester.pumpAndSettle();
      expect(find.text('প্রশ্ন ২ / ২'), findsOneWidget);

      // Submit exam
      await tester.tap(find.text('জমা দিন'));
      await tester.pumpAndSettle();

      expect(find.text('পরীক্ষা সফলভাবে সম্পন্ন হয়েছে!'), findsOneWidget);
      expect(find.text('উত্তরমালা ও ব্যাখ্যা'), findsOneWidget);
    });
  });
}
