
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/home/home.dart';

class SeeAllItemsController extends GetxController {
  final RxString? selectedFilter = "all".obs;

  // Common States
  RxBool isLoading = true.obs;
  RxInt currentExamPage = 1.obs;
  RxInt totalExamPages = 1.obs;
  RxInt currentCoursePage = 1.obs;
  RxInt totalCoursePages = 1.obs;

  // Exams
  Rx<AllExamModel> allExamModel = AllExamModel().obs;
  Rx<ApiCallStatus> examApiCallStatus = ApiCallStatus.holding.obs;

  // Courses
  Rx<AllCourseModel> allCourseModel = AllCourseModel().obs;
  Rx<ApiCallStatus> courseApiCallStatus = ApiCallStatus.holding.obs;

  // Fetch All Exams
  Future<void> fetchAllExams({int page = 1}) async {
    final token = MySharedPref.getUserToken();
    examApiCallStatus.value = ApiCallStatus.loading;

    final url = AppConstants.examList;
    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      headers: {'Authorization': 'Bearer $token'},
      queryParameters: {
        'page': page,
        "type": selectedFilter!.value,
      },
      onSuccess: (response) {
        if (response.data["status"] == true) {
          final modelData = AllExamModel.fromJson(response.data);
          allExamModel.value = modelData;
          currentExamPage.value = page;
          totalExamPages.value = modelData.exams?.lastPage ?? 1;
          examApiCallStatus.value = ApiCallStatus.success;
        } else {
          examApiCallStatus.value = ApiCallStatus.error;
        }
      },
      onError: (err) {
        examApiCallStatus.value = ApiCallStatus.error;
      },
    );
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
