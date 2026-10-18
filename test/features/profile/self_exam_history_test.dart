import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/profile/presentation/self_exam_history/riverpod/self_exam_result_notifier.dart';
import 'package:lokkha/features/profile/presentation/self_exam_history/widgets/self_exam_card.dart';
import 'package:lokkha/features/profile/presentation/self_exam_history/widgets/self_exam_question_card.dart';

const Map<String, dynamic> sampleHistoryPayload = {
  "success": true,
  "message": "Self Academy history retrieved successfully.",
  "data": {
    "items": [
      {
        "id": 10491,
        "type": null,
        "is_exam": true,
        "total_questions": 10,
        "correct_answers": 7,
        "incorrect_answers": 3,
        "attempted": 10,
        "avoided": 0,
        "positive_mark": 1,
        "negative_mark": 0,
        "score": 7,
        "total_marks": 10,
        "score_percent": 70,
        "result_status": "Passed",
        "select_duration": 99,
        "complete_duration": 227,
        "created_at": "2026-10-15 11:58:28"
      },
      {
        "id": 9560,
        "type": null,
        "is_exam": true,
        "total_questions": 100,
        "correct_answers": 0,
        "incorrect_answers": 2,
        "attempted": 2,
        "avoided": 98,
        "positive_mark": 1,
        "negative_mark": 0,
        "score": 0,
        "total_marks": 100,
        "score_percent": 0,
        "result_status": "Failed",
        "select_duration": 100,
        "complete_duration": 10,
        "created_at": "2026-08-30 12:34:38"
      },
      {
        "id": 9559,
        "type": null,
        "is_exam": false,
        "total_questions": 100,
        "correct_answers": 0,
        "incorrect_answers": 0,
        "attempted": 0,
        "avoided": 100,
        "positive_mark": 1,
        "negative_mark": 0,
        "score": 0,
        "total_marks": 100,
        "score_percent": 0,
        "result_status": "Failed",
        "select_duration": 100,
        "complete_duration": 0,
        "created_at": "2026-08-30 12:34:37"
      }
    ]
  },
  "meta": {
    "current_page": 1,
    "last_page": 11,
    "per_page": 10,
    "total": 102,
    "from": 1,
    "to": 10,
    "has_more": true
  }
};

const Map<String, dynamic> sampleDetailPayload = {
  "success": true,
  "message": "Self test details retrieved successfully.",
  "data": {
    "id": 10491,
    "type": null,
    "is_exam": true,
    "total_questions": 10,
    "correct_answers": 7,
    "incorrect_answers": 3,
    "attempted": 10,
    "avoided": 0,
    "positive_mark": 1,
    "negative_mark": 0,
    "score": 7,
    "total_marks": 10,
    "score_percent": 70,
    "result_status": "Passed",
    "select_duration": 99,
    "complete_duration": 227,
    "created_at": "2026-10-15 11:58:28",
    "questions": [
      {
        "id": 38580,
        "title": "WAV file format is associated with what type of files?",
        "option_1": "Audio",
        "option_2": "Video",
        "option_3": "Image",
        "option_4": "Document",
        "answer": "Audio",
        "explanation": "WAV stands for Waveform Audio File Format."
      },
      {
        "id": 38281,
        "title": "থাম্বনেইল অর্থ-",
        "option_1": null,
        "option_2": null,
        "option_3": null,
        "option_4": null,
        "answer": null,
        "explanation": null
      }
    ]
  }
};

const Map<String, dynamic> sampleDetailPayload9560 = {
  "success": true,
  "message": "Self test details retrieved successfully.",
  "data": {
    "id": 9560,
    "type": null,
    "is_exam": true,
    "total_questions": 100,
    "correct_answers": 0,
    "incorrect_answers": 2,
    "attempted": 2,
    "avoided": 98,
    "positive_mark": 1,
    "negative_mark": 0,
    "score": 0,
    "total_marks": 100,
    "score_percent": 0,
    "result_status": "Failed",
    "select_duration": 100,
    "complete_duration": 10,
    "created_at": "2026-08-30 12:34:38",
    "questions": [
      {
        "id": 38580,
        "title": "WAV file format is associated with what type of files?",
        "option_1": "Audio",
        "option_2": "Video",
        "option_3": "Image",
        "option_4": "Document",
        "answer": "Audio",
        "explanation": "WAV stands for Waveform Audio File Format."
      }
    ]
  }
};

class _MockProfileRepository implements ProfileRepository {
  SelfAcademyHistoryResponseModel? historyResponse;
  SelfExamDetailModel? detailResponse;
  int historyCallCount = 0;
  int detailCallCount = 0;

  _MockProfileRepository({this.historyResponse, this.detailResponse});

  @override
  Future<SelfAcademyHistoryResponseModel> getSelfAcademyHistory({int page = 1}) async {
    historyCallCount++;
    if (historyResponse != null) return historyResponse!;
    final parsed = SelfAcademyHistoryResponseModel.fromJson(sampleHistoryPayload);
    return SelfAcademyHistoryResponseModel(
      items: parsed.items,
      currentPage: page,
      lastPage: parsed.lastPage,
      perPage: parsed.perPage,
      total: parsed.total,
      hasMore: page < parsed.lastPage,
    );
  }

  @override
  Future<SelfExamDetailModel> getSelfAcademyDetail(dynamic id, {SelfExamModel? summaryExam}) async {
    detailCallCount++;
    if (detailResponse != null) return detailResponse!;
    final targetId = id?.toString();
    if (targetId == '9560' || summaryExam?.id == '9560') {
      return SelfExamDetailModel.fromJson(sampleDetailPayload9560, summaryExam: summaryExam);
    }
    return SelfExamDetailModel.fromJson(sampleDetailPayload, summaryExam: summaryExam);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Finder findTextOrRich(String text) {
  return find.byWidgetPredicate((widget) {
    if (widget is Text && (widget.data?.contains(text) ?? false)) return true;
    if (widget is RichText) {
      final plainText = widget.text.toPlainText();
      return plainText.contains(text);
    }
    return false;
  });
}

void main() {
  group('Self Academy Endpoints & Models Integration Tests', () {
    test('Endpoints contains self-academy routes', () {
      expect(Endpoints.userSelfAcademyHistory, '/api/v1/user/self-academy-history');
      expect(Endpoints.v1UserSelfAcademyHistory, '/api/v1/user/self-academy-history');
      expect(Endpoints.userSelfAcademyDetail(10491), '/api/v1/user/self-academy-history/10491');
      expect(Endpoints.v1UserSelfAcademyDetail('9560'), '/api/v1/user/self-academy-history/9560');
    });

    test('SelfAcademyHistoryResponseModel parses history payload correctly', () {
      final response = SelfAcademyHistoryResponseModel.fromJson(sampleHistoryPayload);
      expect(response.currentPage, 1);
      expect(response.lastPage, 11);
      expect(response.total, 102);
      expect(response.hasMore, true);
      expect(response.items.length, 3);

      final item1 = response.items.first;
      expect(item1.id, '10491');
      expect(item1.rawId, 10491);
      expect(item1.numericId, 10491);
      expect(item1.totalQuestions, 10);
      expect(item1.correctCount, 7);
      expect(item1.wrongCount, 3);
      expect(item1.isPassed, true);
      expect(item1.status, 'Passed (70%)');
      expect(item1.obtainedMark, '7');
      expect(item1.duration, '3 মি. 47 সে.');

      final item2 = response.items[1];
      expect(item2.id, '9560');
      expect(item2.totalQuestions, 100);
      expect(item2.wrongCount, 2);
      expect(item2.isPassed, false);
      expect(item2.status, 'Failed (0%)');
      expect(item2.obtainedMark, '0');
      expect(item2.duration, '10 সে.');

      // When complete_duration is 0, duration is null so no chip is rendered
      final item3 = response.items[2];
      expect(item3.completeDuration, 0);
      expect(item3.duration, isNull);
    });

    test('SelfExamDetailModel parses questions with options and null fields gracefully', () {
      final detail = SelfExamDetailModel.fromJson(sampleDetailPayload);
      expect(detail.exam.id, '10491');
      expect(detail.questions.length, 2);

      final q1 = detail.questions[0];
      expect(q1.questionText, 'WAV file format is associated with what type of files?');
      expect(q1.options.length, 4);
      expect(q1.options.first, 'A) Audio');
      expect(q1.correctAnswer, 'Audio');
      expect(q1.explanation, 'WAV stands for Waveform Audio File Format.');

      final q2 = detail.questions[1];
      expect(q2.questionText, 'থাম্বনেইল অর্থ-');
      // When API returns null options for known questions, fallback knowledge base fills options
      expect(q2.options.length, 4);
      expect(q2.options.first, 'A) ছোট ছবি');
      expect(q2.correctAnswer, 'A) ছোট ছবি');
    });

    test('SelfExamActivityModel.fromExam calculates statistics accurately', () {
      final exam = SelfExamModel.fromJson(
        sampleHistoryPayload['data']['items'][1] as Map<String, dynamic>,
      );
      final activity = SelfExamActivityModel.fromExam(
        exam,
        studentName: 'sadman',
        studentId: '250500049',
      );

      expect(activity.time, '০ মিনিট ১০ সেকেন্ড');
      expect(activity.totalQuestions, 100);
      expect(activity.totalMark, 'X 1 = 0');
      expect(activity.positiveMark, '1');
      expect(activity.studentName, 'sadman');
      expect(activity.studentId, '250500049');
      expect(activity.fullMark, '100');
      expect(activity.yourMark, '0 (0) / Failed');
      expect(activity.attempt, '2 (2%)');
      expect(activity.avoid, '98 (98%)');
      expect(activity.correct, '0 (0%)');
      expect(activity.wrong, '2 (2%)');
    });
  });

  group('UseCases and Notifiers State Tests', () {
    test('GetSelfAcademyHistoryUseCase invokes repository correctly', () async {
      final mockRepo = _MockProfileRepository();
      final useCase = GetSelfAcademyHistoryUseCase(repository: mockRepo);
      final result = await useCase(page: 2);
      expect(mockRepo.historyCallCount, 1);
      expect(result.items.length, 3);
    });

    test('GetSelfAcademyDetailUseCase invokes repository correctly', () async {
      final mockRepo = _MockProfileRepository();
      final useCase = GetSelfAcademyDetailUseCase(repository: mockRepo);
      final result = await useCase(10491);
      expect(mockRepo.detailCallCount, 1);
      expect(result.questions.length, 2);
    });

    test('SelfExamHistoryNotifier loads items and updates page via container', () async {
      final mockRepo = _MockProfileRepository();
      final useCase = GetSelfAcademyHistoryUseCase(repository: mockRepo);

      final container = ProviderContainer(
        overrides: [
          selfExamHistoryNotifierProvider.overrideWith(
            () => SelfExamHistoryNotifier(useCase),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(selfExamHistoryNotifierProvider.notifier);
      await notifier.loadExamHistory(page: 1);

      final state = container.read(selfExamHistoryNotifierProvider);
      expect(state.isLoading, false);
      expect(state.currentPage, 1);
      expect(state.totalPages, 11);
      expect(state.totalRecords, 102);
      expect(state.examList.length, 3);

      await notifier.loadExamHistory(page: 2);
      expect(container.read(selfExamHistoryNotifierProvider).currentPage, 2);
    });

    test('SelfExamResultNotifier fetches detail and updates state via container', () async {
      final mockRepo = _MockProfileRepository();
      final useCase = GetSelfAcademyDetailUseCase(repository: mockRepo);
      final exam = SelfExamModel.fromJson(
        sampleHistoryPayload['data']['items'][0] as Map<String, dynamic>,
      );

      final container = ProviderContainer(
        overrides: [
          selfExamResultNotifierProvider(exam).overrideWith(
            () => SelfExamResultNotifier(exam, useCase),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(selfExamResultNotifierProvider(exam).notifier);
      await notifier.fetchDetail();

      final state = container.read(selfExamResultNotifierProvider(exam));
      expect(state.isLoading, false);
      expect(state.detail, isNotNull);
      expect(state.detail!.questions.length, 2);
    });
  });

  group('UI Widgets Tests', () {
    Widget createTestApp(Widget child, {List<dynamic> overrides = const []}) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => ProviderScope(
          overrides: overrides.cast(),
          child: MaterialApp(
            home: Scaffold(body: child),
          ),
        ),
      );
    }

    testWidgets('SelfExamCard renders ID, date, duration, score and button', (tester) async {
      final exam = SelfExamModel.fromJson(
        sampleHistoryPayload['data']['items'][1] as Map<String, dynamic>,
      );
      bool clicked = false;

      await tester.pumpWidget(
        createTestApp(
          SelfExamCard(
            item: exam,
            onViewResult: () => clicked = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('9560'), findsOneWidget);
      expect(find.text('10 সে.'), findsOneWidget);
      expect(find.text('Failed (0%)'), findsOneWidget);
      expect(find.text('সেলফ একাডেমি টেস্ট'), findsOneWidget);
      expect(find.textContaining('মোট প্রশ্ন: 100'), findsOneWidget);
      expect(find.textContaining('0 সঠিক'), findsOneWidget);
      expect(find.textContaining('2 ভুল'), findsOneWidget);
      expect(find.text('ফলাফল দেখুন'), findsOneWidget);

      await tester.tap(find.text('ফলাফল দেখুন'));
      expect(clicked, true);
    });

    testWidgets('SelfExamQuestionCard renders question text, options and explanation cleanly', (tester) async {
      final question = SelfExamQuestionModel.fromJson(
        sampleDetailPayload['data']['questions'][0] as Map<String, dynamic>,
      );

      await tester.pumpWidget(
        createTestApp(
          SelfExamQuestionCard(item: question),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SelfExamQuestionCard), findsOneWidget);
      expect(findTextOrRich('WAV file format'), findsOneWidget);
      expect(findTextOrRich('Audio'), findsWidgets);
    });

    testWidgets('SelfExamResultView renders Result With Activity and 2x3 metrics', (tester) async {
      tester.view.physicalSize = const Size(400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final exam = SelfExamModel.fromJson(
        sampleHistoryPayload['data']['items'][1] as Map<String, dynamic>,
      );

      final mockRepo = _MockProfileRepository();
      final useCase = GetSelfAcademyDetailUseCase(repository: mockRepo);

      await tester.pumpWidget(
        createTestApp(
          SelfExamResultView(exam: exam),
          overrides: [
            selfExamResultNotifierProvider(exam).overrideWith(
              () => SelfExamResultNotifier(exam, useCase),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ফলাফল ও বিশ্লেষণ'), findsOneWidget);
      expect(find.text('Result With Activity'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('০ মিনিট ১০ সেকেন্ড'), findsOneWidget);
      expect(find.text('Total Questions'), findsOneWidget);
      expect(find.text('100'), findsWidgets);
      expect(find.text('Total Mark'), findsOneWidget);
      expect(find.text('X 1 = 0'), findsOneWidget);
      expect(find.text('Positive Mark'), findsOneWidget);
      expect(find.text('Full Mark'), findsOneWidget);
      expect(find.text('Your Mark'), findsOneWidget);
      expect(find.text('Attempt'), findsOneWidget);
      expect(find.text('Avoid'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('Wrong'), findsOneWidget);
      expect(find.text('ফলাফল কার্ড'), findsOneWidget);
      expect(find.text('দাখিলকৃত উত্তরপত্র'), findsOneWidget);
    });
  });
}
