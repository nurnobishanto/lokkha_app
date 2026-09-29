import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/core/constants/app_constants.dart';

import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class MyPackagesController extends GetxController {
  // Data Model
  Rx<MyPackagesModel> model = MyPackagesModel().obs;

  // API Call Status
  var apiCallStatus = ApiCallStatus.holding.obs;

  // Fetch Packages from API
  Future<void> fetchMyPackages() async {
    apiCallStatus.value = ApiCallStatus.loading;
    String? token = MySharedPref.getUserToken();
    String url = AppConstants.myPackages;

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
          model.value = MyPackagesModel.fromJson(response.data);
          apiCallStatus.value = ApiCallStatus.success;
        } else {
          apiCallStatus.value = ApiCallStatus.error;
          CustomSnackBar.showCustomErrorToast(
              message: response.data['message'] ?? "প্যাকেজ লোড করতে ব্যর্থ");
        }
      },
      onError: (error) {
        apiCallStatus.value = ApiCallStatus.error;
        debugPrint("MyPackages API Error: $error");
        CustomSnackBar.showCustomErrorToast(
            message: "সার্ভার সংযোগে সমস্যা হয়েছে");
      },
    );
  }

  @override
  void onInit() {
    fetchMyPackages();
    AuthService().authCheck();
    super.onInit();
  }
}
