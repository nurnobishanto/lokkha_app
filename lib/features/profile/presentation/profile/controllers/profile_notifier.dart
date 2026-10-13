import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/services/storage/app_storage_cache.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/navigation/data/models/profile_data_model.dart';
import 'package:lokkha/features/profile/domain/repositories/profile_repository.dart';
import 'package:lokkha/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lokkha/features/profile/domain/usecases/get_profile_usecase.dart';

class ProfileState {
  final bool isLoading;
  final ProfileDataModel? profileDataModel;
  final ApiCallStatus profileApiStatus;

  const ProfileState({
    this.isLoading = true,
    this.profileDataModel,
    this.profileApiStatus = ApiCallStatus.holding,
  });

  ProfileState copyWith({
    bool? isLoading,
    ProfileDataModel? Function()? profileDataModel,
    ApiCallStatus? profileApiStatus,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profileDataModel: profileDataModel != null ? profileDataModel() : this.profileDataModel,
      profileApiStatus: profileApiStatus ?? this.profileApiStatus,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  final GetProfileUseCase _getProfileUseCase =
      GetProfileUseCase(repository: ProfileRepository());

  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> fetchProfileData() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        profileApiStatus: ApiCallStatus.error,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      profileApiStatus: ApiCallStatus.loading,
    );

    try {
      final user = await _getProfileUseCase();
      if (user != null) {
        myUser = user;
        MyGetStorage.writeCacheData(MyGetStorage.meUser, myUser);
        final profileModel = ProfileDataModel(status: true, user: user);
        isLoggedIn.value = true;

        state = state.copyWith(
          isLoading: false,
          profileDataModel: () => profileModel,
          profileApiStatus: ApiCallStatus.success,
        );

        return;
      }
      state = state.copyWith(
        isLoading: false,
        profileApiStatus: ApiCallStatus.error,
      );
    } catch (e) {
      debugPrint("Error fetching profile data (Riverpod): $e");
      state = state.copyWith(
        isLoading: false,
        profileApiStatus: ApiCallStatus.error,
      );
    }
  }

  Future<void> logout() async {
    await AuthService().logout();
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
