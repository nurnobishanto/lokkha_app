import 'package:lokkha/app/data/local/my_get_storage.dart';
import 'package:lokkha/app/data/local/my_shared_pref.dart';
import 'package:lokkha/app/modules/exam_category/views/exam_category_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lokkha/app/modules/premium_packages/views/premium_packages_view.dart';
import '../../../../utils/constants.dart';
import '../../../helper/global.dart';
import '../../../models/user.dart';
import '../../../services/api_call_status.dart';
import '../../../services/auth_service.dart';
import '../../../services/base_client.dart';
import '../../messanger_redirect/messenger_redirect.dart';
import '../../profile_module/dashboard_portal/views/dashboard_portal_view.dart';
import '../../nav_bar_views/home/views/home_view.dart';
import '../model/profile_data_model.dart';

class NavbarController extends GetxController {
  int currentIndex = 0;

  final List<Widget> nabBarBody = [
    const HomeView(),
    const ExamCategoryView(),
    const MessengerRedirectScreen(),
    const PremiumPackagesView(),
    const DashboardPortalView(),
  ];

  void changeIndex(int index) {
    currentIndex = index;
    update();
  }

  ///  Rx nullable
  Rxn<ProfileDataModel> profileDataModel = Rxn<ProfileDataModel>();
  Rx<ApiCallStatus> getProfileApiStatus = ApiCallStatus.holding.obs;
  Future<void> getMeProfileInfo() async {
    debugPrint(" Called Get Me Profile Information");
    final token = MySharedPref.getUserToken();
    if (token.isEmpty) {
      debugPrint("❌ Token is empty, skipping profile fetch.");
      clearProfileState(); // optionally clear previous data
      return;
    }
    getProfileApiStatus.value = ApiCallStatus.loading;
    var url = AppConstants.me;

    await BaseClient.safeApiCall(
      url,
      RequestType.post,
      headers: {'Authorization': 'Bearer $token'},
      onSuccess: (response) {
        final isSuccess = response.data['status'] == true;
        getProfileApiStatus.value = ApiCallStatus.success;
        if (isSuccess) {
          profileDataModel.value = ProfileDataModel.fromJson(response.data);
          MyGetStorage.writeCacheData(
              MyGetStorage.meUser, profileDataModel.value!.user);
          myUser = profileDataModel.value!.user!;
          isLoggedIn.value = true;
          AuthService().authCheck();
          debugPrint("✅ Profile Data fetch Success");
          debugPrint(myUser.name);
        } else {
          debugPrint("⚠️ Profile fetch failed: API status false");
          final msg = response.data['message']?.toString().toLowerCase() ?? '';
          if (msg.contains('unauthenticated') ||
              msg.contains('expired') ||
              msg.contains('token')) {
            AuthService().handleSessionExpired(
              message: response.data['message']?.toString(),
            );
          } else {
            clearProfileState();
          }
        }
      },
      onError: (error) {
        getProfileApiStatus.value = ApiCallStatus.error;
        debugPrint("❌ Profile Fetch Error: $error");
        clearProfileState();
      },
    );
  }

  void clearProfileState() {
    isLoggedIn.value = false;
    profileDataModel.value = null;
    MyGetStorage.removeCache(MyGetStorage.meUser);
    myUser = User();
    MySharedPref.removeUserToken();
  }

  @override
  void onInit() {
    AuthService().authCheck();
    getMeProfileInfo();

    super.onInit();
  }
}
