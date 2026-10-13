import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/profile/domain/repositories/profile_repository.dart';
import 'package:lokkha/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:lokkha/features/profile/presentation/profile/riverpod/profile_notifier.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class ProfileUpdateState {
  final String gender;
  final String dob;
  final CroppedFile? croppedImage;
  final bool isLoading;

  const ProfileUpdateState({
    this.gender = 'অন্যান্য',
    this.dob = '',
    this.croppedImage,
    this.isLoading = false,
  });

  ProfileUpdateState copyWith({
    String? gender,
    String? dob,
    CroppedFile? croppedImage,
    bool? isLoading,
  }) {
    return ProfileUpdateState(
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      croppedImage: croppedImage ?? this.croppedImage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileUpdateNotifier extends Notifier<ProfileUpdateState> {
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final ChangePasswordUseCase _changePasswordUseCase;
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();

  @override
  ProfileUpdateState build() {
    _updateProfileUseCase = UpdateProfileUseCase(repository: ProfileRepository());
    _changePasswordUseCase = ChangePasswordUseCase(repository: ProfileRepository());

    final user = myUser;
    String initialDob = '';
    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      initialDob = user.dateOfBirth!.split("T").first.split(" ").first;
    }
    String initialGender = 'অন্যান্য';
    if (user.gender != null && user.gender!.isNotEmpty) {
      final reverseMap = {
        'male': 'পুরুষ',
        'female': 'মহিলা',
        'other': 'অন্যান্য',
        'others': 'অন্যান্য',
      };
      initialGender = reverseMap[user.gender!.toLowerCase()] ?? 'অন্যান্য';
    }

    return ProfileUpdateState(
      dob: initialDob,
      gender: initialGender,
    );
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setDob(String dob) {
    state = state.copyWith(dob: dob);
  }

  String genderSelect() {
    final map = {
      'পুরুষ': 'male',
      'মহিলা': 'female',
      'অন্যান্য': 'other',
    };
    return map[state.gender] ?? 'other';
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      state = state.copyWith(dob: picked.toIso8601String().split("T").first);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await _imageCropper.cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            statusBarColor: LightThemeColors.primaryColor,
            toolbarColor: LightThemeColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            cropGridColor: LightThemeColors.primaryColor,
            cropFrameColor: LightThemeColors.primaryColor,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile != null) {
        state = state.copyWith(croppedImage: croppedFile);
      }
    }
  }

  Future<bool> updateProfileInfo({
    required BuildContext context,
    required String name,
    required String email,
    required String organization,
    required String occupation,
    required String currentPwd,
    required String newPwd,
    required String confirmPwd,
  }) async {
    if (name.trim().isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "নাম আবশ্যক",
        message: "আপনার নাম প্রদান করা বাধ্যতামূলক। অনুগ্রহ করে সঠিকভাবে লিখুন।",
      );
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      File? photoFile;
      if (state.croppedImage != null) {
        photoFile = File(state.croppedImage!.path);
      }

      final res = await _updateProfileUseCase(
        name: name.trim(),
        email: email.trim(),
        gender: genderSelect(),
        dateOfBirth: state.dob.trim().isNotEmpty ? state.dob.trim() : null,
        occupation: occupation.trim(),
        organization: organization.trim(),
        photoFile: photoFile,
      );

      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        if (newPwd.trim().isNotEmpty) {
          if (currentPwd.trim().isEmpty) {
            CustomSnackBar.showCustomErrorSnackBar(
              title: "পাসওয়ার্ড পরিবর্তন",
              message: "পাসওয়ার্ড পরিবর্তন করতে বর্তমান পাসওয়ার্ড প্রদান করুন।",
            );
          } else if (newPwd.trim() != confirmPwd.trim()) {
            CustomSnackBar.showCustomErrorSnackBar(
              title: "পাসওয়ার্ড মিলছে না",
              message: "পাসওয়ার্ড এবং নিশ্চিতকরণ পাসওয়ার্ড এক হতে হবে।",
            );
          } else {
            await _changePasswordUseCase(
              currentPassword: currentPwd.trim(),
              newPassword: newPwd.trim(),
              confirmPassword: confirmPwd.trim(),
            );
          }
        }

        CustomSnackBar.showCustomToast(
          message: res['message']?.toString() ?? "প্রোফাইল সফলভাবে আপডেট হয়েছে!",
        );

        ref.read(profileNotifierProvider.notifier).fetchProfileData();

        state = state.copyWith(isLoading: false);
        return true;
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "আপডেট ব্যর্থ",
          message: res['message']?.toString() ?? "প্রোফাইল আপডেট সম্পন্ন করা সম্ভব হয়নি।",
        );
        state = state.copyWith(isLoading: false);
        return false;
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
      CustomSnackBar.showCustomErrorSnackBar(
        title: "ত্রুটি",
        message: "সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।",
      );
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

final profileUpdateNotifierProvider =
    NotifierProvider<ProfileUpdateNotifier, ProfileUpdateState>(ProfileUpdateNotifier.new);
