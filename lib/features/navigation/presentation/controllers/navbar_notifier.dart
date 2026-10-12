import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/services/storage/my_get_storage.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/navigation/data/models/profile_data_model.dart';
import 'package:lokkha/shared/models/user.dart';

class NavbarState {
  final int currentIndex;
  final ProfileDataModel? profile;
  final ApiCallStatus profileStatus;
  final bool isLoggedIn;

  const NavbarState({
    this.currentIndex = 0,
    this.profile,
    this.profileStatus = ApiCallStatus.holding,
    this.isLoggedIn = false,
  });

  NavbarState copyWith({
    int? currentIndex,
    ProfileDataModel? Function()? profile,
    ApiCallStatus? profileStatus,
    bool? isLoggedIn,
  }) {
    return NavbarState(
      currentIndex: currentIndex ?? this.currentIndex,
      profile: profile != null ? profile() : this.profile,
      profileStatus: profileStatus ?? this.profileStatus,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class NavbarNotifier extends Notifier<NavbarState> {
  @override
  NavbarState build() {
    return NavbarState(
      currentIndex: 0,
      isLoggedIn: isLoggedIn.value,
    );
  }

  void changeIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  Future<void> fetchProfileInfo() => getMeProfileInfo();

  Future<void> getMeProfileInfo() async {
    debugPrint("Called Get Me Profile Information (Riverpod)");
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      debugPrint("❌ Token is empty, skipping profile fetch.");
      clearProfileState();
      return;
    }

    state = state.copyWith(profileStatus: ApiCallStatus.loading);

    try {
      final response = await ApiClient.get(AppConstants.v1UserProfile);
      if (response.statusCode == 200 && response.data is Map) {
        final profile = ProfileDataModel.fromJson(response.data as Map<String, dynamic>);
        if (profile.status == true && profile.user != null) {
          myUser = profile.user!;
          MyGetStorage.writeCacheData(MyGetStorage.meUser, myUser);
          isLoggedIn.value = true;

          state = state.copyWith(
            profile: () => profile,
            isLoggedIn: true,
            profileStatus: ApiCallStatus.success,
          );

          debugPrint("✅ Profile Data fetch Success: ${myUser.name}");
          return;
        }
      }
      state = state.copyWith(profileStatus: ApiCallStatus.error);
    } on DioException catch (e) {
      state = state.copyWith(profileStatus: ApiCallStatus.error);
      debugPrint("❌ Profile Fetch Error: ${e.response?.statusCode} - ${e.message}");
      if (e.response?.statusCode == 401) {
        AuthService().handleSessionExpired();
      }
    } catch (e) {
      state = state.copyWith(profileStatus: ApiCallStatus.error);
      debugPrint("❌ Profile Fetch Error: $e");
    }
  }

  void clearProfileState() {
    isLoggedIn.value = false;
    myUser = User();
    MyGetStorage.removeCache(MyGetStorage.meUser);
    SecureStorageService.clearAuthData();
    MySharedPref.removeUserToken();

    state = state.copyWith(
      profile: () => null,
      isLoggedIn: false,
      profileStatus: ApiCallStatus.holding,
    );
  }
}

final navbarNotifierProvider = NotifierProvider<NavbarNotifier, NavbarState>(NavbarNotifier.new);
