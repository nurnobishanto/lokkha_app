import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/profile/presentation/live_contest/widgets/live_contest_item_card.dart';
import 'package:lokkha/features/profile/presentation/live_contest/widgets/live_contest_summary_header.dart';
import 'package:lokkha/features/profile/presentation/live_contest/widgets/saved_question_item_card.dart';

const Map<String, dynamic> sampleContentHistoryPayload = {
  "success": true,
  "message": "Content history overview retrieved successfully.",
  "data": {
    "summary": {
      "total_contests": 2,
      "total_saved_questions": 1,
    },
    "recent_contests": [
      {
        "id": 146,
        "contest_id": 43,
        "contest_title": "Contest #43",
        "total_questions": 0,
        "correct_answers": 0,
        "incorrect_answers": 0,
        "score": 0,
        "positive_mark": 1,
        "negative_mark": 0.25,
        "select_duration": 20,
        "complete_duration": 0,
        "participated_at": "2026-04-21 13:00:41",
      },
      {
        "id": 31,
        "contest_id": 12,
        "contest_title": "Quiz Contest 1",
        "total_questions": 30,
        "correct_answers": 3,
        "incorrect_answers": 7,
        "score": 1.25,
        "positive_mark": 1,
        "negative_mark": 0.25,
        "select_duration": 15,
        "complete_duration": 70,
        "participated_at": "2025-05-13 04:24:18",
      },
    ],
    "recent_saved_questions": [
      {
        "saved_id": 2254,
        "question_id": 86887,
        "title":
            "<p>কতটি পৌরসভা ও গ্রামীণ উপজেলায় ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপনের পাইলট প্রকল্প গ্রহণ করা হয়েছে?</p>",
        "options": {
          "option_1": null,
          "option_2": null,
          "option_3": null,
          "option_4": null,
        },
        "answer": null,
        "explanation":
            "<p>ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপনের জন্য ভূমি মন্ত্রণালয়ের অনুমোদিত প্রকল্পে ১টি পৌরসভা ও ২টি গ্রামীণ উপজেলা অন্তর্ভুক্ত রয়েছে। &bull; প্রকল্পের নাম: ডিজিটাল পদ্ধতিতে ভূমি জরিপের মাধ্যমে ৩টি সিটি কর্পোরেশন, ১টি পৌরসভা এবং ২টি গ্রামীণ উপজেলায় ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপন (২য় সংশোধিত)। &bull; মূল লক্ষ্য: আধুনিক প্রযুক্তির মাধ্যমে ভূমি জরিপ ও ব্যবস্থাপনা কার্যক্রম আরও গতিশীল ও স্বচ্ছ করা।</p>",
        "saved_at": "2026-10-15 12:34:00",
      },
    ],
  },
};

class FakeProfileRepository implements ProfileRepository {
  final ContentHistoryResponseModel responseToReturn;

  FakeProfileRepository({required this.responseToReturn});

  @override
  Future<ContentHistoryResponseModel> getContentHistory() async {
    return responseToReturn;
  }

  @override
  Future<bool> toggleSaveQuestion(int questionId) async {
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Live Contest & Content History Endpoints & Models Tests', () {
    test('Endpoints contains v1ContentHistory and v1ToggleSaveQuestion', () {
      expect(Endpoints.v1ContentHistory, '/api/v1/user/content-history');
      expect(Endpoints.v1ToggleSaveQuestion,
          '/api/v1/user/content-history/toggle-save-question');
    });

    test('ContentHistoryResponseModel parses API payload correctly', () {
      final model =
          ContentHistoryResponseModel.fromJson(sampleContentHistoryPayload);

      expect(model.success, true);
      expect(model.message, 'Content history overview retrieved successfully.');
      expect(model.summary.totalContests, 2);
      expect(model.summary.totalSavedQuestions, 1);
      expect(model.recentContests.length, 2);
      expect(model.recentSavedQuestions.length, 1);

      // Check Contest 1
      final contest1 = model.recentContests[0];
      expect(contest1.id, 146);
      expect(contest1.contestId, 43);
      expect(contest1.contestTitle, 'Contest #43');
      expect(contest1.score, 0);
      expect(contest1.formattedScore, '0');
      expect(contest1.positiveMark, 1);
      expect(contest1.negativeMark, 0.25);
      expect(contest1.completeDuration, 0);
      expect(contest1.formattedDuration, isNull);
      expect(contest1.formattedDate, contains('2026'));

      // Check Contest 2
      final contest2 = model.recentContests[1];
      expect(contest2.id, 31);
      expect(contest2.contestId, 12);
      expect(contest2.contestTitle, 'Quiz Contest 1');
      expect(contest2.totalQuestions, 30);
      expect(contest2.correctAnswers, 3);
      expect(contest2.incorrectAnswers, 7);
      expect(contest2.score, 1.25);
      expect(contest2.formattedScore, '1.25');
      expect(contest2.completeDuration, 70);
      expect(contest2.formattedDuration, '1 মি. 10 সে.');
      expect(contest2.accuracy, 30.0);
      expect(contest2.isCompleted, true);

      // Check Saved Question
      final savedQ = model.recentSavedQuestions[0];
      expect(savedQ.savedId, 2254);
      expect(savedQ.questionId, 86887);
      expect(savedQ.cleanTitle,
          'কতটি পৌরসভা ও গ্রামীণ উপজেলায় ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপনের পাইলট প্রকল্প গ্রহণ করা হয়েছে?');
      expect(savedQ.explanation, contains('ডিজিটাল ভূমি ব্যবস্থাপনা'));
      expect(savedQ.formattedSavedDate, contains('2026'));
    });
  });

  group('UseCases and State Management Tests', () {
    test('GetContentHistoryUseCase delegates to repository', () async {
      final parsed =
          ContentHistoryResponseModel.fromJson(sampleContentHistoryPayload);
      final fakeRepo = FakeProfileRepository(responseToReturn: parsed);
      final useCase = GetContentHistoryUseCase(repository: fakeRepo);

      final result = await useCase();
      expect(result.summary.totalContests, 2);
      expect(result.recentContests.length, 2);
    });

    test('ToggleSaveQuestionUseCase delegates to repository', () async {
      final parsed =
          ContentHistoryResponseModel.fromJson(sampleContentHistoryPayload);
      final fakeRepo = FakeProfileRepository(responseToReturn: parsed);
      final useCase = ToggleSaveQuestionUseCase(repository: fakeRepo);

      final success = await useCase(86887);
      expect(success, true);
    });

    test('LiveContestNotifier filter switching and optimistic bookmark remove',
        () async {
      final parsed =
          ContentHistoryResponseModel.fromJson(sampleContentHistoryPayload);

      final fakeRepo = FakeProfileRepository(responseToReturn: parsed);
      final container = ProviderContainer(
        overrides: [
          liveContestNotifierProvider.overrideWith(() => LiveContestNotifier(
                getContentHistoryUseCase:
                    GetContentHistoryUseCase(repository: fakeRepo),
                toggleSaveQuestionUseCase:
                    ToggleSaveQuestionUseCase(repository: fakeRepo),
              )),
        ],
      );

      final notifier = container.read(liveContestNotifierProvider.notifier);
      expect(container.read(liveContestNotifierProvider).activeFilter, 'all');

      notifier.setFilter('contests');
      expect(
          container.read(liveContestNotifierProvider).activeFilter, 'contests');

      notifier.setFilter('saved');
      expect(container.read(liveContestNotifierProvider).activeFilter, 'saved');

      // Test state with data
      notifier.state =
          notifier.state.copyWith(contentHistory: parsed, isLoading: false);
      expect(notifier.state.totalContests, 2);
      expect(notifier.state.totalSavedQuestions, 1);
    });
  });

  group('UI Widgets Tests', () {
    Widget createTestApp(Widget child) {
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, _) => MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );
    }

    testWidgets('LiveContestSummaryHeader renders metric counts and CTA banner',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          LiveContestSummaryHeader(
            totalContests: 2,
            totalSavedQuestions: 1,
            activeFilter: 'all',
            onFilterChanged: (_) {},
            onBrowseContests: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('লাইভ কনটেস্ট'), findsNWidgets(2));
      expect(find.text('সংরক্ষিত প্রশ্ন'), findsNWidgets(2));
      expect(find.text('2'), findsNWidgets(2));
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('লাইভ কনটেস্টে অংশ নিন'), findsOneWidget);
      expect(find.text('চলমান কনটেস্ট'), findsOneWidget);
    });

    testWidgets('LiveContestItemCard renders contest details, marks and buttons',
        (tester) async {
      final parsed =
          ContentHistoryResponseModel.fromJson(sampleContentHistoryPayload);
      final contest = parsed.recentContests[1]; // Quiz Contest 1

      await tester.pumpWidget(
        createTestApp(
          LiveContestItemCard(
            item: contest,
            onViewRanking: () {},
            onViewResult: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('#31'), findsOneWidget);
      expect(find.text('Quiz Contest 1'), findsOneWidget);
      expect(find.text('স্কোর: 1.25'), findsOneWidget);
      expect(find.text('মোট প্রশ্ন'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('সঠিক উত্তর'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('ভুল উত্তর'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('1 মি. 10 সে.'), findsOneWidget);
      expect(find.text('র‍্যাংকিং'), findsOneWidget);
      expect(find.text('ফলাফল'), findsOneWidget);
    });

    testWidgets('SavedQuestionItemCard renders question text and explanation',
        (tester) async {
      final parsed =
          ContentHistoryResponseModel.fromJson(sampleContentHistoryPayload);
      final savedQ = parsed.recentSavedQuestions[0];

      await tester.pumpWidget(
        createTestApp(
          SavedQuestionItemCard(
            item: savedQ,
            onRemove: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('#86887'), findsOneWidget);
      expect(find.text('ব্যাখ্যা ও বিস্তারিত'), findsOneWidget);
      expect(find.text('কপি করুন'), findsOneWidget);
      expect(find.text('প্র্যাকটিস করুন'), findsOneWidget);
    });

    testWidgets('LiveContestView renders with sample state cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final parsed =
          ContentHistoryResponseModel.fromJson(sampleContentHistoryPayload);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveContestNotifierProvider.overrideWith(() {
              final fakeRepo = FakeProfileRepository(responseToReturn: parsed);
              return LiveContestNotifier(
                initialState: LiveContestState(
                  isLoading: false,
                  contentHistory: parsed,
                  activeFilter: 'all',
                ),
                getContentHistoryUseCase:
                    GetContentHistoryUseCase(repository: fakeRepo),
                toggleSaveQuestionUseCase:
                    ToggleSaveQuestionUseCase(repository: fakeRepo),
              );
            }),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, _) => const MaterialApp(
              home: LiveContestView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('লাইভ কনটেস্ট ও সেভড প্রশ্ন'), findsOneWidget);
      expect(find.text('লাইভ কনটেস্ট হিস্ট্রি'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Contest #43'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Contest #43'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Quiz Contest 1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Quiz Contest 1'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('#86887'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('#86887'), findsOneWidget);
    });
  });
}
