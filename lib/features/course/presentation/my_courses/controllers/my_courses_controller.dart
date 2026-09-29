import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/shared/shared.dart';

class MyCoursesController extends GetxController {
  // Data Model
  Rx<MyCourseModel> model = MyCourseModel().obs;

  // API Call Status
  var apiCallStatus = ApiCallStatus.holding.obs;

  // Fetch My Courses from API
  Future<void> fetchMyCourses() async {
    apiCallStatus.value = ApiCallStatus.loading;
    String? token = MySharedPref.getUserToken();
    String url = AppConstants.myCourses;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    await BaseClient.safeApiCall(
      url,
      headers: headers,
      RequestType.post,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          model.value = MyCourseModel.fromJson(response.data);
          apiCallStatus.value = ApiCallStatus.success;
        } else {
          apiCallStatus.value = ApiCallStatus.error;
          CustomSnackBar.showCustomErrorToast(
              message: response.data['message'] ?? "কোর্স লোড করতে ব্যর্থ");
        }
      },
      onError: (error) {
        apiCallStatus.value = ApiCallStatus.error;
        debugPrint("MyCourses API Error: $error");
        CustomSnackBar.showCustomErrorToast(
            message: "সার্ভার সংযোগে সমস্যা হয়েছে");
      },
    );
  }

  @override
  void onInit() {
    fetchMyCourses();
    super.onInit();
  }
}