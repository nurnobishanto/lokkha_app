import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/models/accuracy_exam_item_model.dart';
import 'package:lokkha/features/profile/data/models/accuracy_metric_model.dart';
import 'package:lokkha/features/profile/data/models/accuracy_response_model.dart';
import 'package:lokkha/features/profile/data/models/accuracy_trend_point_model.dart';
import 'package:lokkha/features/profile/data/models/exam_history_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_accuracy_analytics_usecase.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_rank_view.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_result_sheet_view.dart';

class AccuracyProgressState {
  final AccuracyResponseModel? responseData;
  final bool isLoading;
  final bool isPaginating;
  final int currentPage;
  final String? errorMessage;
  final AccuracyMetricModel? _legacyMetrics;
  final List<AccuracyTrendPointModel>? _legacyTrendPoints;
  final List<AccuracyExamItemModel>? _legacyExamList;

  const AccuracyProgressState({
    this.responseData,
    this.isLoading = false,
    this.isPaginating = false,
    this.currentPage = 1,
    this.errorMessage,
    AccuracyMetricModel? metrics,
    List<AccuracyTrendPointModel>? trendPoints,
    List<AccuracyExamItemModel>? examList,
  })  : _legacyMetrics = metrics,
        _legacyTrendPoints = trendPoints,
        _legacyExamList = examList;

  AccuracyMetricsDataModel get metrics {
    if (responseData != null) {
      return responseData!.metrics;
    }
    final legacy = _legacyMetrics;
    if (legacy != null) {
      return AccuracyMetricsDataModel(
        accuracyRate: double.tryParse(
              legacy.avgAccuracy.replaceAll('%', '').trim(),
            ) ??
            0.0,
        highestAccuracy: double.tryParse(
              legacy.highestAccuracy.replaceAll('%', '').trim(),
            ) ??
            0.0,
        totalQuestionsAnswered: legacy.totalQuestionsAnswered,
        totalCorrectAnswers: legacy.correctCount,
        totalIncorrectAnswers: legacy.wrongCount,
      );
    }
    return const AccuracyMetricsDataModel();
  }

  AccuracyChartDataModel get chart {
    if (responseData != null) {
      return responseData!.chart;
    }
    final legacyPoints = _legacyTrendPoints;
    if (legacyPoints != null && legacyPoints.isNotEmpty) {
      return AccuracyChartDataModel(
        labels: legacyPoints.map((p) => p.date).toList(),
        data: legacyPoints.map((p) => p.percentage).toList(),
      );
    }
    return const AccuracyChartDataModel();
  }

  List<AccuracyExamItemModel> get examList {
    if (responseData != null) {
      return responseData!.history.items;
    }
    final legacyExams = _legacyExamList;
    return legacyExams ?? const [];
  }

  ExamHistoryMetaModel get meta =>
      responseData?.history.meta ??
      ExamHistoryMetaModel(
        currentPage: currentPage,
        lastPage: 1,
        total: examList.length,
      );

  List<AccuracyTrendPointModel> get trendPoints {
    final legacyPoints = _legacyTrendPoints;
    if (legacyPoints != null && legacyPoints.isNotEmpty) {
      return legacyPoints;
    }
    return chart.toLegacyTrendPoints();
  }

  AccuracyProgressState copyWith({
    AccuracyResponseModel? responseData,
    bool? isLoading,
    bool? isPaginating,
    int? currentPage,
    String? errorMessage,
    bool clearError = false,
    AccuracyMetricModel? metrics,
    List<AccuracyTrendPointModel>? trendPoints,
    List<AccuracyExamItemModel>? examList,
  }) {
    return AccuracyProgressState(
      responseData: responseData ?? this.responseData,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      metrics: metrics ?? _legacyMetrics,
      trendPoints: trendPoints ?? _legacyTrendPoints,
      examList: examList ?? _legacyExamList,
    );
  }
}

class AccuracyProgressNotifier extends Notifier<AccuracyProgressState> {
  final GetAccuracyAnalyticsUseCase _getAccuracyAnalyticsUseCase;
  final AccuracyProgressState? _initialState;

  AccuracyProgressNotifier({
    GetAccuracyAnalyticsUseCase? getAccuracyAnalyticsUseCase,
    AccuracyProgressState? initialState,
  })  : _getAccuracyAnalyticsUseCase =
            getAccuracyAnalyticsUseCase ?? GetAccuracyAnalyticsUseCase(),
        _initialState = initialState;

  @override
  AccuracyProgressState build() {
    if (_initialState != null) {
      return _initialState!;
    }
    Future.microtask(() => loadAccuracyAnalytics(page: 1));
    return const AccuracyProgressState(isLoading: true);
  }

  Future<void> loadAccuracyAnalytics({
    int page = 1,
    bool isRefresh = false,
  }) async {
    if (isRefresh || page == 1) {
      state = state.copyWith(
        isLoading: true,
        isPaginating: false,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        isPaginating: true,
        clearError: true,
      );
    }

    try {
      final response = await _getAccuracyAnalyticsUseCase(page: page);
      state = state.copyWith(
        responseData: response,
        currentPage: page,
        isLoading: false,
        isPaginating: false,
        clearError: true,
      );
    } catch (e) {
      debugPrint('[AccuracyProgressNotifier] loadAccuracyAnalytics error: $e');
      state = state.copyWith(
        isLoading: false,
        isPaginating: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> changePage(int page) async {
    if (page == state.currentPage || state.isPaginating || state.isLoading) {
      return;
    }
    await loadAccuracyAnalytics(page: page);
  }

  Future<void> refresh() async {
    await loadAccuracyAnalytics(page: 1, isRefresh: true);
  }

  void viewRanking(BuildContext context, AccuracyExamItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamRankView(
          exam: ExamHistoryModel(
            id: item.id.startsWith('#') ? item.id : "#${item.id}",
            date: item.date,
            status: item.status,
            isPassed: item.isPassed,
            title: item.title,
            totalQuestions: item.totalQuestions,
            correctCount: item.correctCount,
            wrongCount: item.wrongCount,
            obtainedMark: item.obtainedMark,
          ),
        ),
      ),
    );
  }

  void viewResult(BuildContext context, AccuracyExamItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamResultSheetView(
          exam: ExamHistoryModel(
            id: item.id.startsWith('#') ? item.id : "#${item.id}",
            date: item.date,
            status: item.status,
            isPassed: item.isPassed,
            title: item.title,
            totalQuestions: item.totalQuestions,
            correctCount: item.correctCount,
            wrongCount: item.wrongCount,
            obtainedMark: item.obtainedMark,
          ),
        ),
      ),
    );
  }
}

final accuracyProgressNotifierProvider =
    NotifierProvider<AccuracyProgressNotifier, AccuracyProgressState>(
  AccuracyProgressNotifier.new,
);
