import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/exam.dart';

class CoursesController extends GetxController {
  final apiCallCoursesStatus = ApiCallStatus.holding.obs;
  final coursesModel = CoursesModel().obs;

  late final int id;
  @override
  void onInit() {
    id = Get.arguments['course_category_id'] as int;
    fetchCourses(id);
    super.onInit();
  }

  /// Fetch Courses Method
  Future<void> fetchCourses(int coursesID) async {
    apiCallCoursesStatus.value = ApiCallStatus.loading;
    try {
      final url = "${AppConstants.courses}?course_category_id=$coursesID";
      await BaseClient.safeApiCall(
        url,
        RequestType.get,
        onSuccess: (response) {
          if (response.data['status']) {
            coursesModel.value = CoursesModel.fromJson(response.data);
            apiCallCoursesStatus.value = ApiCallStatus.success;
          } else {
            apiCallCoursesStatus.value = ApiCallStatus.error;
          }
        },
        onError: (err) {
          apiCallCoursesStatus.value = ApiCallStatus.error;
          debugPrint("error from fetchCourses $err");
        },
      );
    } catch (e) {
      apiCallCoursesStatus.value = ApiCallStatus.error;
    }
  }
}
