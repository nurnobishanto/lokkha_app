import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/features/profile/profile.dart';

class ProfileController extends GetxController {
  final GetProfileUseCase _getProfileUseCase =
      GetProfileUseCase(repository: ProfileRepository());

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
      final user = await _getProfileUseCase();
      if (user != null) {
        myUser = user;
        MyGetStorage.writeCacheData(MyGetStorage.meUser, myUser);
        profileDataModel.value = ProfileDataModel(status: true, user: user);
        isLoggedIn.value = true;
        profileApiStatus.value = ApiCallStatus.success;
        update();
        return;
      }
      profileApiStatus.value = ApiCallStatus.error;
    } catch (e) {
      debugPrint("Error fetching profile data: $e");
      profileApiStatus.value = ApiCallStatus.error;
    }
  }

  Future<void> logout() async {
    await AuthService().logout();
  }
}
