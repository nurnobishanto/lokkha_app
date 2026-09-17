import 'package:get/get.dart';
import '../models/exam_history_model.dart';
import '../views/exam_rank_view.dart';
import '../views/exam_result_sheet_view.dart';

class ProfileHistoryController extends GetxController {
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 3.obs;
  final RxInt totalRecords = 25.obs;
  final RxBool isLoading = false.obs;

  final RxList<ExamHistoryModel> examList = <ExamHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadExamHistory(page: 1);
  }

  void loadExamHistory({required int page}) {
    currentPage.value = page;

    // Sample data matching the screenshots
    if (page == 1) {
      examList.value = [
        const ExamHistoryModel(
          id: "#9163",
          date: "13 May, 2026 • 01:22 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "পরীক্ষা-৪৪ বাংলাদেশ বিষয়াবলী রাজনৈতিক ব্যবস্থ ....",
          totalQuestions: 30,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
        const ExamHistoryModel(
          id: "#4099",
          date: "23 Dec, 2025 • 01:53 PM",
          status: "Failed (-2.5%)",
          isPassed: false,
          title: "বাংলা সাহিত্যের আধুনিক যুগ",
          totalQuestions: 20,
          correctCount: 0,
          wrongCount: 1,
          obtainedMark: "-0.5",
        ),
        const ExamHistoryModel(
          id: "#4089",
          date: "23 Dec, 2025 • 12:14 PM",
          status: "Failed (-5%)",
          isPassed: false,
          title: "সমাস",
          totalQuestions: 20,
          correctCount: 0,
          wrongCount: 2,
          obtainedMark: "-1",
        ),
        const ExamHistoryModel(
          id: "#4064",
          date: "22 Dec, 2025 • 04:34 PM",
          status: "Failed (-5%)",
          isPassed: false,
          title: "সমাস",
          totalQuestions: 20,
          correctCount: 0,
          wrongCount: 2,
          obtainedMark: "-1",
        ),
      ];
    } else if (page == 2) {
      examList.value = [
        const ExamHistoryModel(
          id: "#3130",
          date: "05 Dec, 2025 • 11:15 AM",
          status: "Failed (0%)",
          isPassed: false,
          title: "প্রাইমারি সহকারী শিক্ষক নিয়োগ পরীক্ষা- ০৯",
          totalQuestions: 30,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
        const ExamHistoryModel(
          id: "#3129",
          date: "01 Dec, 2025 • 03:00 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "বাংলা সাহিত্যের মধ্যযুগ",
          totalQuestions: 25,
          correctCount: 1,
          wrongCount: 2,
          obtainedMark: "0",
        ),
        const ExamHistoryModel(
          id: "#3128",
          date: "01 Dec, 2025 • 02:43 PM",
          status: "Failed (7.5%)",
          isPassed: false,
          title: "সমাস",
          totalQuestions: 20,
          correctCount: 2,
          wrongCount: 1,
          obtainedMark: "1.5",
        ),
      ];
    } else {
      examList.value = [
        const ExamHistoryModel(
          id: "#3127",
          date: "01 Dec, 2025 • 02:43 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "প্রণালী, সীমারেখা ও অন্যান্য ভৌগোলিক বিষয় সম্পর্কিত",
          totalQuestions: 15,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
      ];
    }
  }

  void onPageChanged(int newPage) {
    if (newPage >= 1 && newPage <= totalPages.value) {
      loadExamHistory(page: newPage);
    }
  }

  void viewRank(ExamHistoryModel item) {
    Get.to(() => ExamRankView(exam: item));
  }

  void viewResultSheet(ExamHistoryModel item) {
    Get.to(() => ExamResultSheetView(exam: item));
  }
}
