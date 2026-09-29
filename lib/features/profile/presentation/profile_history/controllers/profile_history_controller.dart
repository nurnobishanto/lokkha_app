import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/profile/profile.dart';

class ProfileHistoryController extends GetxController {
  final GetExamHistoryUseCase getExamHistoryUseCase;

  ProfileHistoryController({
    GetExamHistoryUseCase? getExamHistoryUseCase,
  }) : getExamHistoryUseCase = getExamHistoryUseCase ?? GetExamHistoryUseCase();

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalRecords = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<ExamHistoryModel> examList = <ExamHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadExamHistory(page: 1);
  }

  Future<void> loadExamHistory({required int page}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = page;

      final response = await getExamHistoryUseCase(page: page);

      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage > 0 ? response.lastPage : 1;
      totalRecords.value = response.total;
      examList.value = response.items;
    } catch (e) {
      debugPrint('[ProfileHistoryController] loadExamHistory error: $e');
      errorMessage.value = 'পরীক্ষার ইতিহাস লোড করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
    } finally {
      isLoading.value = false;
    }
  }

  void onPageChanged(int newPage) {
    if (newPage >= 1 && newPage <= totalPages.value && newPage != currentPage.value) {
      loadExamHistory(page: newPage);
    }
  }

  Future<void> onRefresh() async {
    await loadExamHistory(page: currentPage.value);
  }

  void viewRank(ExamHistoryModel item) {
    Get.to(() => ExamRankView(exam: item));
  }

  void viewResultSheet(ExamHistoryModel item) {
    Get.to(() => ExamResultSheetView(exam: item));
  }
}
