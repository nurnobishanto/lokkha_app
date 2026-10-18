import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/services/storage/app_storage_cache.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';
import 'package:lokkha/features/navigation/data/models/profile_data_model.dart';
import 'package:lokkha/shared/models/user.dart';

class NavbarState {
  final int currentIndex;
  final ProfileDataModel? profile;
  final bool isProfileLoading;
  final bool isLoggedIn;

  const NavbarState({
    this.currentIndex = 0,
    this.profile,
    this.isProfileLoading = false,
    this.isLoggedIn = false,
  });

  NavbarState copyWith({
    int? currentIndex,
    ProfileDataModel? Function()? profile,
    bool? isProfileLoading,
    bool? isLoggedIn,
  }) {
    return NavbarState(
      currentIndex: currentIndex ?? this.currentIndex,
      profile: profile != null ? profile() : this.profile,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
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
    var token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      final prefToken = MySharedPref.getUserToken();
      if (prefToken.isNotEmpty) token = prefToken;
    }
    if ((token == null || token.isEmpty) && myUser.jwtToken != null && myUser.jwtToken!.isNotEmpty) {
      token = myUser.jwtToken;
    }
    if (token == null || token.isEmpty) {
      debugPrint("❌ Token is empty, skipping profile fetch.");
      clearProfileState();
      return;
    }

    state = state.copyWith(isProfileLoading: true);

    try {
      final response = await RestClient().get(Endpoints.v1UserProfile);
      if (response.statusCode == 200 && response.data is Map) {
        final profile = ProfileDataModel.fromJson(response.data as Map<String, dynamic>);
        if (profile.status == true && profile.user != null) {
          myUser = profile.user!;
          MyGetStorage.writeCacheData(MyGetStorage.meUser, myUser);
          isLoggedIn.value = true;
          havePackage.value = profile.user?.hasActiveSubscription == true ||
              profile.user?.isSubscribed == true ||
              profile.user?.activePackage != null ||
              checkUserHasPackage();

          state = state.copyWith(
            profile: () => profile,
            isLoggedIn: true,
            isProfileLoading: false,
          );

          try {
            ref.read(myCoursesNotifierProvider.notifier).fetchMyCourses(isRefresh: true);
          } catch (_) {}

          debugPrint("✅ Profile Data fetch Success: ${myUser.name}");
          return;
        }
      }
      state = state.copyWith(isProfileLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isProfileLoading: false);
      debugPrint("❌ Profile Fetch Error: ${e.response?.statusCode} - ${e.message}");
      if (e.response?.statusCode == 401) {
        AuthService().handleSessionExpired();
      }
    } catch (e) {
      state = state.copyWith(isProfileLoading: false);
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
      isProfileLoading: false,
    );
  }
}

final navbarNotifierProvider = NotifierProvider<NavbarNotifier, NavbarState>(NavbarNotifier.new);
