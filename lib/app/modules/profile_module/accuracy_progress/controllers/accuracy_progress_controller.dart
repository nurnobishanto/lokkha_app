import 'package:get/get.dart';
import '../../profile_history/models/exam_history_model.dart';
import '../../profile_history/views/exam_rank_view.dart';
import '../../profile_history/views/exam_result_sheet_view.dart';
import '../models/accuracy_exam_item_model.dart';
import '../models/accuracy_metric_model.dart';
import '../models/accuracy_trend_point_model.dart';

class AccuracyProgressController extends GetxController {
  final Rx<AccuracyMetricModel> metrics = const AccuracyMetricModel(
    avgAccuracy: "2.2%",
    highestAccuracy: "15%",
    totalQuestionsAnswered: 630,
    correctCount: 14,
    wrongCount: 38,
  ).obs;

  final RxList<AccuracyTrendPointModel> trendPoints = <AccuracyTrendPointModel>[].obs;
  final RxList<AccuracyExamItemModel> examList = <AccuracyExamItemModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    // Trend points matching media_1789642066293.png
    trendPoints.value = [
      const AccuracyTrendPointModel(date: "02 Nov", percentage: 15.0),
      const AccuracyTrendPointModel(date: "02 Nov", percentage: 0.0),
      const AccuracyTrendPointModel(date: "02 Nov", percentage: 0.0),
      const AccuracyTrendPointModel(date: "06 Nov", percentage: 0.0),
      const AccuracyTrendPointModel(date: "10 Nov", percentage: 12.0),
      const AccuracyTrendPointModel(date: "01 Dec", percentage: 0.0),
      const AccuracyTrendPointModel(date: "01 Dec", percentage: 10.0),
      const AccuracyTrendPointModel(date: "01 Dec", percentage: 0.0),
      const AccuracyTrendPointModel(date: "03 Dec", percentage: 0.0),
      const AccuracyTrendPointModel(date: "03 Dec", percentage: 0.0),
      const AccuracyTrendPointModel(date: "04 Dec", percentage: 5.0),
      const AccuracyTrendPointModel(date: "22 Dec", percentage: 0.0),
      const AccuracyTrendPointModel(date: "23 Dec", percentage: 0.0),
      const AccuracyTrendPointModel(date: "23 Dec", percentage: 0.0),
      const AccuracyTrendPointModel(date: "13 May", percentage: 0.0),
    ];

    // Exam items matching media_1789642083668.png
    examList.value = [
      const AccuracyExamItemModel(
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
      const AccuracyExamItemModel(
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
      const AccuracyExamItemModel(
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
    ];
  }

  void viewRanking(AccuracyExamItemModel item) {
    Get.to(() => ExamRankView(
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
        ));
  }

  void viewResult(AccuracyExamItemModel item) {
    Get.to(() => ExamResultSheetView(
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
        ));
  }
}
