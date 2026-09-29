import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/features/course/course.dart';

class CourseDetailsController extends GetxController {
  late final int courseId;
  CourseDetailsModel model = CourseDetailsModel();
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    courseId = Get.arguments['course_id'] as int;
    fetchCourseDetails(courseId);
  }

  RxBool showFullDetails = false.obs;
  void toggleDetails() {
    showFullDetails.value = !showFullDetails.value;
  }

  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  Future<void> fetchCourseDetails(int id) async {
    apiCallStatus = ApiCallStatus.loading;
    String? token = MySharedPref.getUserToken();
    isLoading = true;
    update(); // Notifies UI
    final headers = {
      'Authorization': 'Bearer $token',
    };

    final url = "${AppConstants.courseDetails}/$courseId";

    try {
      BaseClient.safeApiCall(url, RequestType.get, headers: headers,
          onSuccess: (response) {
        if (response.data['status']) {
          apiCallStatus = ApiCallStatus.success;
          isLoading = false;
          model = CourseDetailsModel.fromJson(response.data);
          update();
        }
      }, onError: (err) {
        apiCallStatus = ApiCallStatus.error;
        if (kDebugMode) print("Error fetching course Details: $err");
        update();
      });
    } catch (e) {
      apiCallStatus = ApiCallStatus.error;
      if (kDebugMode) print("Error fetching course Details: $e");
      update();
    } finally {
      isLoading = false;
      update(); // Final UI update
    }
  }
}
