import 'package:get/get.dart';
import '../models/self_exam_model.dart';
import '../views/self_exam_result_view.dart';

class SelfExamHistoryController extends GetxController {
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 3.obs;
  final RxInt totalRecords = 25.obs;
  final RxBool isLoading = false.obs;

  final RxList<SelfExamModel> examList = <SelfExamModel>[].obs;

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
        const SelfExamModel(
          id: "9560",
          date: "30 Aug, 2026 • 06:34 PM",
          duration: "10 সে.",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 100,
          correctCount: 0,
          wrongCount: 2,
          obtainedMark: "0",
        ),
        const SelfExamModel(
          id: "9559",
          date: "30 Aug, 2026 • 06:34 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 100,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
        const SelfExamModel(
          id: "9558",
          date: "30 Aug, 2026 • 06:34 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 97,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
        const SelfExamModel(
          id: "9557",
          date: "30 Aug, 2026 • 06:32 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 97,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
      ];
    } else if (page == 2) {
      examList.value = [
        const SelfExamModel(
          id: "9556",
          date: "28 Aug, 2026 • 11:20 AM",
          duration: "15 সে.",
          status: "Passed (85%)",
          isPassed: true,
          title: "সেলফ একাডেমি টেস্ট - সাধারণ জ্ঞান",
          totalQuestions: 50,
          correctCount: 42,
          wrongCount: 4,
          obtainedMark: "41.0",
        ),
        const SelfExamModel(
          id: "9555",
          date: "25 Aug, 2026 • 04:10 PM",
          status: "Passed (70%)",
          isPassed: true,
          title: "সেলফ একাডেমি টেস্ট - বাংলা ব্যাকরণ",
          totalQuestions: 50,
          correctCount: 35,
          wrongCount: 5,
          obtainedMark: "33.75",
        ),
      ];
    } else {
      examList.value = [
        const SelfExamModel(
          id: "9550",
          date: "20 Aug, 2026 • 02:15 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 30,
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

  void viewResult(SelfExamModel item) {
    Get.to(() => SelfExamResultView(exam: item));
  }
}
