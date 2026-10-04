import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/exam.dart';

class CoursesController extends GetxController {
  final apiCallCoursesStatus = ApiCallStatus.holding.obs;
  final coursesModel = CoursesModel().obs;

  int? id;

  @override
  void onInit() {
    super.onInit();
    id = _extractCourseCategoryId();
    fetchCourses(id);
  }

  /// Safely extract category id from arguments or URL parameters
  int? _extractCourseCategoryId() {
    // 1. Check URL parameters (e.g. /courses?course_category_id=5)
    if (Get.parameters.isNotEmpty) {
      final param = Get.parameters['course_category_id'] ??
          Get.parameters['category_id'] ??
          Get.parameters['id'];
      if (param != null && param.isNotEmpty) {
        final parsed = int.tryParse(param);
        if (parsed != null) return parsed;
      }
    }

    // 2. Check Get.arguments
    final args = Get.arguments;
    if (args != null) {
      if (args is int) {
        return args;
      }
      if (args is String) {
        return int.tryParse(args);
      }
      if (args is Map) {
        final rawId = args['course_category_id'] ??
            args['category_id'] ??
            args['id'];
        if (rawId is int) return rawId;
        if (rawId != null) return int.tryParse(rawId.toString());
      }
    }

    return null;
  }

  /// Fetch Courses Method (loads specific category if ID provided, or all courses if null)
  Future<void> fetchCourses([int? coursesID]) async {
    apiCallCoursesStatus.value = ApiCallStatus.loading;
    try {
      final url = (coursesID != null && coursesID > 0)
          ? "${AppConstants.courses}?course_category_id=$coursesID"
          : AppConstants.courses;

      await BaseClient.safeApiCall(
        url,
        RequestType.get,
        onSuccess: (response) {
          if (response.data != null && response.data['status'] == true) {
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
      debugPrint("exception in fetchCourses $e");
    }
  }
}
