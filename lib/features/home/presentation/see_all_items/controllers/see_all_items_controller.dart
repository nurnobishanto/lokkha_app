
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/shared/models/exam.dart';

class SeeAllItemsController extends GetxController {
  final GetUserExamsUseCase _getUserExamsUseCase;

  SeeAllItemsController({GetUserExamsUseCase? getUserExamsUseCase})
      : _getUserExamsUseCase = getUserExamsUseCase ??
            (Get.isRegistered<GetUserExamsUseCase>()
                ? Get.find<GetUserExamsUseCase>()
                : GetUserExamsUseCase());

  final RxString selectedFilter = "all".obs;

  // Common States
  RxBool isLoading = true.obs;
  RxInt currentExamPage = 1.obs;
  RxInt totalExamPages = 1.obs;
  RxInt currentCoursePage = 1.obs;
  RxInt totalCoursePages = 1.obs;

  // Exams
  Rx<AllExamModel> allExamModel = AllExamModel().obs;
  RxList<Exam> examsList = <Exam>[].obs;
  RxList<UserExamV1Item> v1ExamsList = <UserExamV1Item>[].obs;
  Rx<UserExamV1Meta?> examMeta = Rx<UserExamV1Meta?>(null);
  Rx<ApiCallStatus> examApiCallStatus = ApiCallStatus.holding.obs;

  // Courses
  Rx<AllCourseModel> allCourseModel = AllCourseModel().obs;
  Rx<ApiCallStatus> courseApiCallStatus = ApiCallStatus.holding.obs;

  void setFilter(String filter) {
    if (selectedFilter.value == filter && filter != 'all') {
      selectedFilter.value = 'all';
    } else {
      selectedFilter.value = filter;
    }
    fetchAllExams(page: 1);
  }

  // Fetch All Exams via Clean Architecture V1 API UseCase
  Future<void> fetchAllExams({int page = 1}) async {
    examApiCallStatus.value = ApiCallStatus.loading;

    try {
      final filterParam =
          selectedFilter.value == 'all' ? null : selectedFilter.value;
      final response = await _getUserExamsUseCase(
        page: page,
        perPage: 10,
        filter: filterParam,
      );

      v1ExamsList.assignAll(response.items);
      final convertedExams =
          response.items.map((item) => item.toExam()).toList();
      examsList.assignAll(convertedExams);
      examMeta.value = response.meta;

      // Keep allExamModel updated for backward compatibility
      allExamModel.value = AllExamModel(
        status: response.success,
        exams: Exams(
          currentPage: response.meta.currentPage,
          lastPage: response.meta.lastPage,
          perPage: response.meta.perPage,
          total: response.meta.total,
          data: convertedExams,
        ),
      );

      currentExamPage.value = response.meta.currentPage;
      totalExamPages.value =
          response.meta.lastPage > 0 ? response.meta.lastPage : 1;
      examApiCallStatus.value = ApiCallStatus.success;
    } catch (e) {
      debugPrint('[SeeAllItemsController] fetchAllExams error: $e');
      examApiCallStatus.value = ApiCallStatus.error;
    }
  }

  // Fetch All Courses
  Future<void> fetchAllCourses({int page = 1}) async {
    courseApiCallStatus.value = ApiCallStatus.loading;
    isLoading.value = true;
    final url = AppConstants.courses;

    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      queryParameters: {'page': page},
      onSuccess: (response) {
        if (response.data["status"] == true) {
          final modelData = AllCourseModel.fromJson(response.data);

          if (page > 1 && allCourseModel.value.courses?.data != null) {
            allCourseModel.value.courses!.data!
                .addAll(modelData.courses!.data!);
            allCourseModel.refresh();
          } else {
            allCourseModel.value = modelData;
          }

          currentCoursePage.value = page;
          totalCoursePages.value = modelData.courses?.lastPage ?? 1;
          courseApiCallStatus.value = ApiCallStatus.success;
        } else {
          courseApiCallStatus.value = ApiCallStatus.error;
        }

        isLoading.value = false;
      },
      onError: (err) {
        courseApiCallStatus.value = ApiCallStatus.error;
        isLoading.value = false;
      },
    );
  }

  // Exam Pagination Helpers
  void goToExamPage(int page) => fetchAllExams(page: page);
  void nextExamPage() => fetchAllExams(page: currentExamPage.value + 1);
  void previousExamPage() => fetchAllExams(page: currentExamPage.value - 1);
  void firstExamPage() => fetchAllExams(page: 1);
  void lastExamPage() => fetchAllExams(page: totalExamPages.value);

  // Course Pagination Helpers
  void goToCoursePage(int page) => fetchAllCourses(page: page);
  void nextCoursePage() => fetchAllCourses(page: currentCoursePage.value + 1);
  void previousCoursePage() =>
      fetchAllCourses(page: currentCoursePage.value - 1);
  void firstCoursePage() => fetchAllCourses(page: 1);
  void lastCoursePage() => fetchAllCourses(page: totalCoursePages.value);

  @override
  void onInit() {
    fetchAllExams();
    fetchAllCourses();
    super.onInit();
  }
}
