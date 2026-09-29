import 'package:get/get.dart';
import 'package:lokkha/features/profile/profile.dart';

class ExamResultSheetController extends GetxController {
  final ExamHistoryModel exam;
  final GetExamHistoryDetailUseCase getExamHistoryDetailUseCase;

  ExamResultSheetController({
    required this.exam,
    GetExamHistoryDetailUseCase? getExamHistoryDetailUseCase,
  }) : getExamHistoryDetailUseCase =
            getExamHistoryDetailUseCase ?? GetExamHistoryDetailUseCase();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ExamReviewDetailModel?> detail = Rx<ExamReviewDetailModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchReview();
  }

  Future<void> fetchReview() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final targetId = exam.numericId > 0 ? exam.numericId : exam.id;
      final result = await getExamHistoryDetailUseCase(
        targetId,
        summaryExam: exam,
      );
      detail.value = result;
    } catch (e) {
      errorMessage.value = "পর্যালোচনা তথ্য লোড করা যায়নি।";
    } finally {
      isLoading.value = false;
    }
  }
}
