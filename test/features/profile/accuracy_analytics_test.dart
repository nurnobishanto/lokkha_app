import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/profile/presentation/accuracy_progress/widgets/accuracy_trend_chart.dart';
import 'package:lokkha/features/profile/presentation/profile_history/widgets/exam_history_pagination.dart';

const Map<String, dynamic> sampleAccuracyPayload = {
  "success": true,
  "message": "Accuracy analytics retrieved successfully.",
  "data": {
    "metrics": {
      "total_questions_answered": 1200,
      "total_correct_answers": 940,
      "total_incorrect_answers": 180,
      "total_avoided_answers": 80,
      "accuracy_rate": 78.3,
      "highest_accuracy": 92.5
    },
    "chart": {
      "labels": ["01 Sep", "05 Sep", "10 Sep", "15 Sep"],
      "data": [65.0, 72.5, 80.0, 78.3],
      "titles": ["Exam 1", "Exam 2", "Exam 3", "Exam 4"],
      "points": [
        {"x": 0, "y": 65.0, "label": "01 Sep", "title": "Exam 1"},
        {"x": 1, "y": 72.5, "label": "05 Sep", "title": "Exam 2"},
        {"x": 2, "y": 80.0, "label": "10 Sep", "title": "Exam 3"},
        {"x": 3, "y": 78.3, "label": "15 Sep", "title": "Exam 4"}
      ]
    },
    "history": {
      "items": [
        {
          "id": "101",
          "date": "2026-09-15 10:00:00",
          "accuracy": 78.3,
          "result_status": "Passed",
          "exam_title": "বিসিএস প্রিলিমিনারি মডেল টেস্ট ১",
          "total_questions": 100,
          "correct_answers": 78,
          "incorrect_answers": 22,
          "score": "78.0"
        },
        {
          "id": "100",
          "date": "2026-09-10 10:00:00",
          "accuracy": 80.0,
          "result_status": "Passed",
          "exam_title": "বিসিএস প্রিলিমিনারি মডেল টেস্ট ২",
          "total_questions": 100,
          "correct_answers": 80,
          "incorrect_answers": 20,
          "score": "80.0"
        }
      ],
      "meta": {
        "current_page": 1,
        "last_page": 3,
        "total": 24,
        "per_page": 10
      }
    }
  }
};

class FakeProfileRepository implements ProfileRepository {
  final AccuracyResponseModel responseModel;
  bool shouldThrow = false;
  int requestedPage = 1;

  FakeProfileRepository({required this.responseModel});

  @override
  Future<AccuracyResponseModel> getAccuracyAnalytics({int page = 1}) async {
    requestedPage = page;
    if (shouldThrow) {
      throw Exception('Server unreachable');
    }
    return responseModel;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget createTestableWidget(Widget child, {List<dynamic> overrides = const []}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        home: child,
      ),
    ),
  );
}

void main() {
  group('Accuracy & Performance Analytics - Model Parsing Tests', () {
    test('parses complete accuracy payload into AccuracyResponseModel', () {
      final model = AccuracyResponseModel.fromJson(sampleAccuracyPayload);

      expect(model.success, isTrue);
      expect(model.message, "Accuracy analytics retrieved successfully.");

      // Metrics
      final metrics = model.metrics;
      expect(metrics.totalQuestionsAnswered, 1200);
      expect(metrics.totalCorrectAnswers, 940);
      expect(metrics.totalIncorrectAnswers, 180);
      expect(metrics.totalAvoidedAnswers, 80);
      expect(metrics.accuracyRate, 78.3);
      expect(metrics.highestAccuracy, 92.5);
      expect(metrics.avgAccuracyStr, "78.3%");
      expect(metrics.highestAccuracyStr, "92.5%");

      // Chart
      final chart = model.chart;
      expect(chart.labels.length, 4);
      expect(chart.labels[0], "01 Sep");
      expect(chart.data, [65.0, 72.5, 80.0, 78.3]);
      expect(chart.titles, ["Exam 1", "Exam 2", "Exam 3", "Exam 4"]);
      expect(chart.flSpots.length, 4);
      expect(chart.flSpots[0].x, 0.0);
      expect(chart.flSpots[0].y, 65.0);
      expect(chart.flSpots[2].y, 80.0);

      // History & Meta
      final history = model.history;
      expect(history.items.length, 2);
      expect(history.items.first.id, "101");
      expect(history.items.first.title, "বিসিএস প্রিলিমিনারি মডেল টেস্ট ১");
      expect(history.items.first.correctCount, 78);
      expect(history.items.first.wrongCount, 22);
      expect(history.items.first.isPassed, isTrue);
      expect(history.meta.currentPage, 1);
      expect(history.meta.lastPage, 3);
      expect(history.meta.total, 24);
    });

    test('handles empty and partial JSON safely with robust fallbacks', () {
      final emptyModel = AccuracyResponseModel.fromJson({});
      expect(emptyModel.metrics.totalQuestionsAnswered, 0);
      expect(emptyModel.metrics.avgAccuracyStr, "0%");
      expect(emptyModel.chart.flSpots, isEmpty);
      expect(emptyModel.history.items, isEmpty);
      expect(emptyModel.history.meta.currentPage, 1);
    });

    test('parses user accuracy data array and generates spots correctly even if points is empty or lists', () {
      final json = {
        "success": true,
        "data": {
          "chart": {
            "labels": [
              "01 Dec", "01 Dec", "01 Dec", "03 Dec", "03 Dec",
              "04 Dec", "05 Dec", "06 Dec", "07 Dec", "08 Dec",
              "09 Dec", "10 Dec", "11 Dec", "12 Dec", "13 Dec"
            ],
            "data": [
              0, 10, 4, 0, 0, 5, 0, 0, 0, 0, 10, 10, 0, 8.3, 0
            ],
            "titles": List.generate(15, (i) => "Exam ${i + 1}"),
            "points": []
          }
        }
      };

      final response = AccuracyResponseModel.fromJson(json);
      final spots = response.chart.flSpots;
      expect(spots.length, 15);
      expect(spots[0].y, 0.0);
      expect(spots[1].y, 10.0);
      expect(spots[2].y, 4.0);
      expect(spots[5].y, 5.0);
      expect(spots[10].y, 10.0);
      expect(spots[11].y, 10.0);
      expect(spots[13].y, 8.3);
      expect(spots[14].y, 0.0);
    });

    test('verifies endpoints constant', () {
      expect(Endpoints.v1UserAccuracy, '/api/v1/user/accuracy');
      expect(Endpoints.accuracy, '/api/v1/user/accuracy');
    });
  });

  group('Accuracy & Performance Analytics - UseCase & Notifier Tests', () {
    test('GetAccuracyAnalyticsUseCase queries repository with given page', () async {
      final fakeRepo = FakeProfileRepository(
        responseModel: AccuracyResponseModel.fromJson(sampleAccuracyPayload),
      );
      final useCase = GetAccuracyAnalyticsUseCase(repository: fakeRepo);

      final result = await useCase(page: 2);
      expect(fakeRepo.requestedPage, 2);
      expect(result.metrics.totalQuestionsAnswered, 1200);
      expect(result.history.items.length, 2);
    });

    test('AccuracyProgressNotifier loads data on initialization', () async {
      final fakeRepo = FakeProfileRepository(
        responseModel: AccuracyResponseModel.fromJson(sampleAccuracyPayload),
      );
      final useCase = GetAccuracyAnalyticsUseCase(repository: fakeRepo);

      final container = ProviderContainer(
        overrides: [
          accuracyProgressNotifierProvider.overrideWith(
            () => AccuracyProgressNotifier(
              getAccuracyAnalyticsUseCase: useCase,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(accuracyProgressNotifierProvider.notifier);
      await notifier.loadAccuracyAnalytics(page: 1);

      final state = container.read(accuracyProgressNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.responseData, isNotNull);
      expect(state.metrics.totalQuestionsAnswered, 1200);
      expect(state.chart.flSpots.length, 4);
      expect(state.examList.length, 2);
    });

    test('AccuracyProgressNotifier handles pagination and page change', () async {
      final fakeRepo = FakeProfileRepository(
        responseModel: AccuracyResponseModel.fromJson(sampleAccuracyPayload),
      );
      final useCase = GetAccuracyAnalyticsUseCase(repository: fakeRepo);

      final container = ProviderContainer(
        overrides: [
          accuracyProgressNotifierProvider.overrideWith(
            () => AccuracyProgressNotifier(
              getAccuracyAnalyticsUseCase: useCase,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(accuracyProgressNotifierProvider.notifier);
      await notifier.loadAccuracyAnalytics(page: 1);

      await notifier.changePage(2);
      expect(fakeRepo.requestedPage, 2);
      expect(container.read(accuracyProgressNotifierProvider).currentPage, 2);
    });

    test('AccuracyProgressNotifier handles error state properly', () async {
      final fakeRepo = FakeProfileRepository(
        responseModel: AccuracyResponseModel.fromJson(sampleAccuracyPayload),
      )..shouldThrow = true;

      final useCase = GetAccuracyAnalyticsUseCase(repository: fakeRepo);
      final container = ProviderContainer(
        overrides: [
          accuracyProgressNotifierProvider.overrideWith(
            () => AccuracyProgressNotifier(
              getAccuracyAnalyticsUseCase: useCase,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(accuracyProgressNotifierProvider.notifier);
      await notifier.loadAccuracyAnalytics(page: 1);

      final state = container.read(accuracyProgressNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('Server unreachable'));
    });
  });

  group('Accuracy & Performance Analytics - Widget Tests', () {
    testWidgets('AccuracyTrendChart displays badges and fl_chart', (tester) async {
      final model = AccuracyResponseModel.fromJson(sampleAccuracyPayload);

      await tester.pumpWidget(
        createTestableWidget(
          Scaffold(
            body: AccuracyTrendChart(
              chart: model.chart,
              avgAccuracy: model.metrics.avgAccuracyStr,
              highestAccuracy: model.metrics.highestAccuracyStr,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("নির্ভুলতা ও পারফরম্যান্স ট্রেন্ড গ্রাফ"), findsOneWidget);
      expect(find.text("গড়: 78.3%"), findsOneWidget);
      expect(find.text("সর্বোচ্চ: 92.5%"), findsOneWidget);
    });

    testWidgets('AccuracyTrendChart displays empty state message when no data exists', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const Scaffold(
            body: AccuracyTrendChart(
              chart: AccuracyChartDataModel(),
              avgAccuracy: "0%",
              highestAccuracy: "0%",
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("পর্যাপ্ত পরীক্ষা দিলে এখানে আপনার নির্ভুলতার গ্রাফ দেখা যাবে।"), findsOneWidget);
    });

    testWidgets('AccuracyProgressView renders summary stats, trend chart, exam cards and pagination', (tester) async {
      tester.view.physicalSize = const Size(400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final model = AccuracyResponseModel.fromJson(sampleAccuracyPayload);
      final fakeRepo = FakeProfileRepository(responseModel: model);
      final useCase = GetAccuracyAnalyticsUseCase(repository: fakeRepo);

      await tester.pumpWidget(
        createTestableWidget(
          const AccuracyProgressView(),
          overrides: [
            accuracyProgressNotifierProvider.overrideWith(
              () => AccuracyProgressNotifier(
                getAccuracyAnalyticsUseCase: useCase,
                initialState: AccuracyProgressState(
                  responseData: model,
                  isLoading: false,
                  currentPage: 1,
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // App Bar
      expect(find.text("গড় নির্ভুলতা ও অগ্রগতি"), findsOneWidget);

      // Summary Cards
      expect(find.text("গড় নির্ভুলতা"), findsOneWidget);
      expect(find.text("78.3%"), findsWidgets);
      expect(find.text("সর্বোচ্চ নির্ভুলতা"), findsOneWidget);
      expect(find.text("92.5%"), findsOneWidget);
      expect(find.text("মোট প্রশ্ন উত্তর"), findsOneWidget);
      expect(find.text("1200"), findsOneWidget);
      expect(find.text("সঠিক বনাম ভুল"), findsOneWidget);

      // Section Header
      expect(find.text("প্রতিটি পরীক্ষার নির্ভুলতা বিবরণী"), findsOneWidget);

      // Exam Cards
      expect(find.text("বিসিএস প্রিলিমিনারি মডেল টেস্ট ১"), findsOneWidget);
      expect(find.text("বিসিএস প্রিলিমিনারি মডেল টেস্ট ২"), findsOneWidget);

      // Pagination widget (since last_page = 3)
      await tester.scrollUntilVisible(
        find.byType(ExamHistoryPagination),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(ExamHistoryPagination), findsOneWidget);
      expect(find.textContaining("টি রেকর্ড"), findsWidgets);
      expect(find.textContaining("24"), findsWidgets);
    });
  });
}
