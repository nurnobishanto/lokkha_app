import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/navigation/data/models/profile_data_model.dart';
import 'package:lokkha/features/profile/domain/repositories/profile_repository.dart';
import 'package:lokkha/features/profile/domain/usecases/get_profile_usecase.dart';

class ProfileState {
  final bool isLoading;
  final bool hasError;
  final ProfileDataModel? profileDataModel;

  const ProfileState({
    this.isLoading = true,
    this.hasError = false,
    this.profileDataModel,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? hasError,
    ProfileDataModel? Function()? profileDataModel,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      profileDataModel: profileDataModel != null ? profileDataModel() : this.profileDataModel,
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
        hasError: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      hasError: false,
    );

    try {
      final user = await _getProfileUseCase();
      if (user != null) {
        myUser = user;
        havePackage.value = user.hasActiveSubscription == true ||
            user.isSubscribed == true ||
            user.activePackage != null;
        final profileModel = ProfileDataModel(status: true, user: user);
        isLoggedIn.value = true;

        state = state.copyWith(
          isLoading: false,
          hasError: false,
          profileDataModel: () => profileModel,
        );

        return;
      }
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    } catch (e) {
      debugPrint("Error fetching profile data (Riverpod): $e");
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> logout() async {
    await AuthService().logout();
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
