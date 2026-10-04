import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/features/course/course.dart';

class CourseDetailsController extends GetxController {
  int? courseId;
  CourseDetailsModel model = CourseDetailsModel();
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    courseId = _extractCourseId();
    if (courseId != null) {
      fetchCourseDetails(courseId!);
    } else {
      apiCallStatus = ApiCallStatus.error;
      isLoading = false;
      update();
    }
  }

  int? _extractCourseId() {
    if (Get.parameters.isNotEmpty) {
      final param = Get.parameters['course_id'] ?? Get.parameters['id'];
      if (param != null && param.isNotEmpty) {
        final parsed = int.tryParse(param);
        if (parsed != null) return parsed;
      }
    }
    final args = Get.arguments;
    if (args != null) {
      if (args is int) return args;
      if (args is String) return int.tryParse(args);
      if (args is Map) {
        final rawId = args['course_id'] ?? args['id'];
        if (rawId is int) return rawId;
        if (rawId != null) return int.tryParse(rawId.toString());
      }
    }
    return null;
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
