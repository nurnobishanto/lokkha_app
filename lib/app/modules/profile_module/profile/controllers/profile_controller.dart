import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/components/custom_snackbar.dart';
import 'package:lokkha/app/data/local/secure_storage_service.dart';
import 'package:lokkha/app/data/network/api_client.dart';
import 'package:lokkha/app/data/repositories/auth_repository.dart';
import 'package:lokkha/app/helper/global.dart';
import 'package:lokkha/app/routes/app_pages.dart';
import 'package:lokkha/app/services/api_call_status.dart';
import 'package:lokkha/utils/constants.dart';
import '../../../navbar/model/profile_data_model.dart';

class ProfileController extends GetxController {
  RxBool isLoading = true.obs;
  Rxn<ProfileDataModel> profileDataModel = Rxn<ProfileDataModel>();
  Rx<ApiCallStatus> profileApiStatus = ApiCallStatus.holding.obs;

  @override
  void onInit() {
    debugPrint("ProfileController initialized");
    fetchProfileData();
    super.onInit();
  }

  Future<void> fetchProfileData() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      profileApiStatus.value = ApiCallStatus.error;
      return;
    }

    profileApiStatus.value = ApiCallStatus.loading;
    try {
      final response = await ApiClient.get(AppConstants.v1AuthMe);
      if (response.statusCode == 200 && response.data is Map) {
        final profile = ProfileDataModel.fromJson(response.data as Map<String, dynamic>);
        if (profile.status == true) {
          profileDataModel.value = profile;
          isLoggedIn.value = true;
          profileApiStatus.value = ApiCallStatus.success;
          return;
        }
      }
      profileApiStatus.value = ApiCallStatus.error;
    } catch (e) {
      profileApiStatus.value = ApiCallStatus.error;
    }
  }

  Future<void> logout() async {
    try {
      await AuthRepository().logout();
      CustomSnackBar.showCustomToast(message: "লগআউট সফল হয়েছে");
    } catch (e) {
      debugPrint("Logout Error: $e");
    } finally {
      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>(force: true);
      }
      Get.offAllNamed(Routes.NAVBAR);
    }
  }
}
