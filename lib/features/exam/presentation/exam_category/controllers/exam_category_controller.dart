import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/core/constants/app_constants.dart';

class ExamCategoryController extends GetxController {
  final model = ExamCategoriesModel().obs;
  final courseCategoriesModel = CourseCategoriesModel().obs;

  final apiCallStatus = ApiCallStatus.holding.obs;
  final apiCallCourseCategoriesStatus = ApiCallStatus.holding.obs;

  /// Fetch Free Exam Categories Method
  Future<void> fetchExamCategories() async {
    apiCallStatus.value = ApiCallStatus.loading;
    try {
      final url = AppConstants.examsCategories;
      await BaseClient.safeApiCall(
        url,
        RequestType.get,
        onSuccess: (response) {
          if (response.data['status']) {
            model.value = ExamCategoriesModel.fromJson(response.data);
            apiCallStatus.value = ApiCallStatus.success;
          } else {
            apiCallStatus.value = ApiCallStatus.error;
          }
        },
        onError: (err) {
          apiCallStatus.value = ApiCallStatus.error;
          debugPrint("error from fetchExamCategories $err");
        },
      );
    } catch (e) {
      apiCallStatus.value = ApiCallStatus.error;
    }
  }

  /// Fetch Course Categories Method
  Future<void> fetchCourseCategories() async {
    apiCallCourseCategoriesStatus.value = ApiCallStatus.loading;
    try {
      final url = AppConstants.courseCategories;
      await BaseClient.safeApiCall(
        url,
        RequestType.get,
        onSuccess: (response) {
          if (response.data['status']) {
            courseCategoriesModel.value =
                CourseCategoriesModel.fromJson(response.data);
            apiCallCourseCategoriesStatus.value = ApiCallStatus.success;
          } else {
            apiCallCourseCategoriesStatus.value = ApiCallStatus.error;
          }
        },
        onError: (err) {
          apiCallCourseCategoriesStatus.value = ApiCallStatus.error;
          debugPrint("error from fetchCourseCategories $err");
        },
      );
    } catch (e) {
      apiCallCourseCategoriesStatus.value = ApiCallStatus.error;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchCourseCategories();
    fetchExamCategories();
  }
}
