import 'package:dio/dio.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/features/app_system/app_system.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/navigation/navigation.dart';

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
    debugPrint("Called Get Me Profile Information");
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      debugPrint("❌ Token is empty, skipping profile fetch.");
      clearProfileState();
      return;
    }
    getProfileApiStatus.value = ApiCallStatus.loading;

    try {
      final response = await ApiClient.get(AppConstants.v1AuthMe);
      if (response.statusCode == 200 && response.data is Map) {
        final profile = ProfileDataModel.fromJson(response.data as Map<String, dynamic>);
        if (profile.status == true && profile.user != null) {
          profileDataModel.value = profile;
          myUser = profile.user!;
          MyGetStorage.writeCacheData(MyGetStorage.meUser, myUser);
          isLoggedIn.value = true;
          getProfileApiStatus.value = ApiCallStatus.success;
          debugPrint("✅ Profile Data fetch Success: ${myUser.name}");
          return;
        }
      }
      getProfileApiStatus.value = ApiCallStatus.error;
    } on DioException catch (e) {
      getProfileApiStatus.value = ApiCallStatus.error;
      debugPrint("❌ Profile Fetch Error: ${e.response?.statusCode} - ${e.message}");
      if (e.response?.statusCode == 401) {
        AuthService().handleSessionExpired();
      }
    } catch (e) {
      getProfileApiStatus.value = ApiCallStatus.error;
      debugPrint("❌ Profile Fetch Error: $e");
    }
  }

  void clearProfileState() {
    isLoggedIn.value = false;
    profileDataModel.value = null;
    MyGetStorage.removeCache(MyGetStorage.meUser);
    myUser = User();
    SecureStorageService.clearAuthData();
    MySharedPref.removeUserToken();
  }

  @override
  void onInit() {
    AuthService().authCheck();
    getMeProfileInfo();

    super.onInit();
  }
}
