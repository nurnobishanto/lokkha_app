import 'package:get/get.dart';
import '../../../../components/custom_snackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../profile_history/models/exam_history_model.dart';
import '../../profile_history/views/exam_rank_view.dart';
import '../../profile_history/views/exam_result_sheet_view.dart';
import '../models/contest_history_item_model.dart';
import '../models/saved_question_item_model.dart';

class ContestHistoryController extends GetxController {
  final RxList<ContestHistoryItemModel> contestList = <ContestHistoryItemModel>[].obs;
  final RxList<SavedQuestionItemModel> savedQuestionList = <SavedQuestionItemModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    // Sample contest history matching media_1789641382548.png
    contestList.value = [
      const ContestHistoryItemModel(
        id: "146",
        date: "21 Apr, 2026 • 07:00 PM",
        title: "লাইভ কনটেস্ট #43",
        correctCount: 0,
        wrongCount: 0,
      ),
      const ContestHistoryItemModel(
        id: "31",
        date: "13 May, 2025 • 10:24 AM",
        duration: "70 সে.",
        title: "Quiz Contest 1",
        correctCount: 3,
        wrongCount: 7,
      ),
    ];

    // Sample saved questions matching media_1789641382548.png
    savedQuestionList.value = [
      const SavedQuestionItemModel(
        id: "62618",
        savedDate: "23 Dec, 2025",
      ),
      const SavedQuestionItemModel(
        id: "62617",
        savedDate: "23 Dec, 2025",
      ),
      const SavedQuestionItemModel(
        id: "62616",
        savedDate: "23 Dec, 2025",
      ),
    ];
  }

  void openLiveContests() {
    Get.toNamed(Routes.ALL_CONTEST);
  }

  void viewRanking(ContestHistoryItemModel item) {
    Get.to(() => ExamRankView(
          exam: ExamHistoryModel(
            id: "#${item.id}",
            date: item.date,
            status: "Completed",
            isPassed: true,
            title: item.title,
            totalQuestions: item.correctCount + item.wrongCount,
            correctCount: item.correctCount,
            wrongCount: item.wrongCount,
            obtainedMark: "${item.correctCount}",
          ),
        ));
  }

  void viewResult(ContestHistoryItemModel item) {
    Get.to(() => ExamResultSheetView(
          exam: ExamHistoryModel(
            id: "#${item.id}",
            date: item.date,
            status: "Completed",
            isPassed: true,
            title: item.title,
            totalQuestions: item.correctCount + item.wrongCount,
            correctCount: item.correctCount,
            wrongCount: item.wrongCount,
            obtainedMark: "${item.correctCount}",
          ),
        ));
  }

  void viewSavedQuestion(SavedQuestionItemModel item) {
    CustomSnackBar.showCustomToast(message: "প্রশ্ন #${item.id} বিস্তারিত প্রস্তুত হচ্ছে...");
  }
}
