import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/models/accuracy_exam_item_model.dart';
import 'package:lokkha/features/profile/data/models/accuracy_metric_model.dart';
import 'package:lokkha/features/profile/data/models/accuracy_trend_point_model.dart';
import 'package:lokkha/features/profile/data/models/exam_history_model.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_rank_view.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_result_sheet_view.dart';

class AccuracyProgressState {
  final AccuracyMetricModel metrics;
  final List<AccuracyTrendPointModel> trendPoints;
  final List<AccuracyExamItemModel> examList;
  final bool isLoading;

  const AccuracyProgressState({
    this.metrics = const AccuracyMetricModel(
      avgAccuracy: "2.2%",
      highestAccuracy: "15%",
      totalQuestionsAnswered: 630,
      correctCount: 14,
      wrongCount: 38,
    ),
    this.trendPoints = const [],
    this.examList = const [],
    this.isLoading = false,
  });

  AccuracyProgressState copyWith({
    AccuracyMetricModel? metrics,
    List<AccuracyTrendPointModel>? trendPoints,
    List<AccuracyExamItemModel>? examList,
    bool? isLoading,
  }) {
    return AccuracyProgressState(
      metrics: metrics ?? this.metrics,
      trendPoints: trendPoints ?? this.trendPoints,
      examList: examList ?? this.examList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AccuracyProgressNotifier extends Notifier<AccuracyProgressState> {
  @override
  AccuracyProgressState build() {
    return const AccuracyProgressState(
      metrics: AccuracyMetricModel(
        avgAccuracy: "2.2%",
        highestAccuracy: "15%",
        totalQuestionsAnswered: 630,
        correctCount: 14,
        wrongCount: 38,
      ),
      trendPoints: [
        AccuracyTrendPointModel(date: "02 Nov", percentage: 15.0),
        AccuracyTrendPointModel(date: "02 Nov", percentage: 0.0),
        AccuracyTrendPointModel(date: "02 Nov", percentage: 0.0),
        AccuracyTrendPointModel(date: "06 Nov", percentage: 0.0),
        AccuracyTrendPointModel(date: "10 Nov", percentage: 12.0),
        AccuracyTrendPointModel(date: "01 Dec", percentage: 0.0),
        AccuracyTrendPointModel(date: "01 Dec", percentage: 10.0),
        AccuracyTrendPointModel(date: "01 Dec", percentage: 0.0),
        AccuracyTrendPointModel(date: "03 Dec", percentage: 0.0),
        AccuracyTrendPointModel(date: "03 Dec", percentage: 0.0),
        AccuracyTrendPointModel(date: "04 Dec", percentage: 5.0),
        AccuracyTrendPointModel(date: "22 Dec", percentage: 0.0),
        AccuracyTrendPointModel(date: "23 Dec", percentage: 0.0),
        AccuracyTrendPointModel(date: "23 Dec", percentage: 0.0),
        AccuracyTrendPointModel(date: "13 May", percentage: 0.0),
      ],
      examList: [
        AccuracyExamItemModel(
          id: "9163",
          date: "13 May, 2026 • 01:22 PM",
          accuracy: "0%",
          status: "Failed",
          isPassed: false,
          title: "পরীক্ষা-৪৪ বাংলাদেশ বিষয়াবলী রাজনৈতিক ব্যবস্থ ....",
          totalQuestions: 30,
          correctCount: 0,
          wrongCount: 0,
          accuracyRatio: "0%",
          obtainedMark: "0",
        ),
        AccuracyExamItemModel(
          id: "4099",
          date: "23 Dec, 2025 • 01:53 PM",
          accuracy: "0%",
          status: "Failed",
          isPassed: false,
          title: "বাংলা সাহিত্যের আধুনিক যুগ",
          totalQuestions: 20,
          correctCount: 0,
          wrongCount: 1,
          accuracyRatio: "0%",
          obtainedMark: "-0.5",
        ),
        AccuracyExamItemModel(
          id: "4089",
          date: "23 Dec, 2025 • 12:14 PM",
          accuracy: "0%",
          status: "Failed",
          isPassed: false,
          title: "সমাস",
          totalQuestions: 20,
          correctCount: 0,
          wrongCount: 2,
          accuracyRatio: "0%",
          obtainedMark: "-1",
        ),
      ],
    );
  }

  void viewRanking(BuildContext context, AccuracyExamItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamRankView(
          exam: ExamHistoryModel(
            id: "#${item.id}",
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
            id: "#${item.id}",
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
    NotifierProvider<AccuracyProgressNotifier, AccuracyProgressState>(AccuracyProgressNotifier.new);
