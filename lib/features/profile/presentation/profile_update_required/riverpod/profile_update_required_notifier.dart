import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class ProfileUpdateRequiredState {
  final String gender;
  final String occupation;
  final bool isLoading;

  const ProfileUpdateRequiredState({
    this.gender = '',
    this.occupation = '',
    this.isLoading = false,
  });

  ProfileUpdateRequiredState copyWith({
    String? gender,
    String? occupation,
    bool? isLoading,
  }) {
    return ProfileUpdateRequiredState(
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileUpdateRequiredNotifier extends Notifier<ProfileUpdateRequiredState> {
  @override
  ProfileUpdateRequiredState build() {
    return const ProfileUpdateRequiredState();
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setOccupation(String occupation) {
    state = state.copyWith(occupation: occupation);
  }

  Future<bool> updateProfileRequired({
    required String name,
    required String phone,
    required String dob,
    required String pwd,
    required String confirmPwd,
  }) async {
    if (name.trim().isEmpty ||
        dob.trim().isEmpty ||
        state.gender.trim().isEmpty ||
        state.occupation.trim().isEmpty ||
        pwd.trim().isEmpty ||
        confirmPwd.trim().isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Missing Information",
        message: "Please fill in all the required fields before continuing.",
      );
      return false;
    }

    if (pwd.trim() != confirmPwd.trim()) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Oops!",
        message: "The password and confirmation password do not match. Please try again.",
      );
      return false;
    }

    state = state.copyWith(isLoading: true);

    final Map<String, dynamic> data = {
      "name": name.trim(),
      "date_of_birth": dob.trim(),
      "gender": state.gender.trim(),
      "phone": phone.trim(),
      "occupation": state.occupation.trim(),
      "password": pwd.trim(),
      "password_confirmation": confirmPwd.trim(),
    };

    try {
      final response = await RestClient().post(
        Endpoints.v1UserProfileUpdate,
        data: data,
      );

      state = state.copyWith(isLoading: false);

      final isSuccess = response.data['status'] == true ||
          response.data['status'] == 1 ||
          response.data['success'] == true;

      if (isSuccess) {
        CustomSnackBar.showCustomToast(
          message: response.data["message"] ?? "প্রোফাইল সফলভাবে আপডেট হয়েছে!",
        );
        isLoggedIn.value = true;
        return true;
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "Update Failed",
          message: response.data["message"] ?? "প্রোফাইল আপডেট করা যায়নি।",
        );
        return false;
      }
    } on DioException catch (error) {
      state = state.copyWith(isLoading: false);
      if (error.response?.data is Map && error.response?.data["errors"] != null) {
        final errors = error.response!.data['errors'];
        if (errors is Map) {
          errors.forEach((key, value) {
            CustomSnackBar.showCustomErrorToast(
              message: value is List ? value.first.toString() : value.toString(),
            );
          });
        }
      } else {
        CustomSnackBar.showCustomToast(
          message: error.message ?? "সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।",
        );
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("Error update Profile Info Required: $e");
      CustomSnackBar.showCustomErrorToast(message: "অপ্রত্যাশিত সমস্যা হয়েছে।");
      return false;
    }
  }
}

final profileUpdateRequiredNotifierProvider =
    NotifierProvider<ProfileUpdateRequiredNotifier, ProfileUpdateRequiredState>(
  ProfileUpdateRequiredNotifier.new,
);
