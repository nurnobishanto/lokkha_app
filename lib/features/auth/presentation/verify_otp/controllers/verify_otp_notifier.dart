import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/app_route_paths.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class VerifyOtpState {
  final bool isLoading;
  final String otp;
  final ApiCallStatus status;
  final String? errorMessage;

  const VerifyOtpState({
    this.isLoading = false,
    this.otp = '',
    this.status = ApiCallStatus.holding,
    this.errorMessage,
  });

  VerifyOtpState copyWith({
    bool? isLoading,
    String? otp,
    ApiCallStatus? status,
    String? errorMessage,
  }) {
    return VerifyOtpState(
      isLoading: isLoading ?? this.isLoading,
      otp: otp ?? this.otp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class VerifyOtpNotifier extends Notifier<VerifyOtpState> {
  @override
  VerifyOtpState build() => const VerifyOtpState();

  void setOtp(String value) {
    state = state.copyWith(otp: value);
  }

  Future<void> sendOtp(String phone, [String type = 'Registration']) async {
    state = state.copyWith(status: ApiCallStatus.loading);

    try {
      final sendOtpUseCase = ref.read(sendOtpUseCaseProvider);
      final res = await sendOtpUseCase(phone, type: type);
      if (res.status) {
        state = state.copyWith(status: ApiCallStatus.success);
        CustomSnackBar.showCustomToast(
          message: res.message ?? "ওটিপি সফলভাবে পাঠানো হয়েছে।",
        );
      } else {
        state = state.copyWith(
          status: ApiCallStatus.error,
          errorMessage: res.message ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে।',
        );
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'OTP Error',
          message: res.message ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে।',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ApiCallStatus.error,
        errorMessage: 'ওটিপি পাঠাতে সমস্যা হয়েছে।',
      );
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'OTP Error',
        message: 'ওটিপি পাঠাতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
      );
    }
  }

  Future<void> register(String phone, BuildContext context) async {
    if (state.otp.trim().length < 6) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Please Fill the pin',
        message: 'OTP must be 6 digits.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, status: ApiCallStatus.loading);

    try {
      final registerUseCase = ref.read(registerUseCaseProvider);
      final res = await registerUseCase(
        phone: phone,
        otp: state.otp.trim(),
      );

      state = state.copyWith(isLoading: false);

      if (res.status) {
        state = state.copyWith(status: ApiCallStatus.success);
        CustomSnackBar.showCustomToast(
          message: res.message ?? "রেজিস্ট্রেশন সফল হয়েছে!",
        );
        if (Get.isRegistered<NavbarController>()) {
          Get.find<NavbarController>().getMeProfileInfo();
        }

        if (context.mounted) {
          try {
            context.go(
              AppRoutePaths.profileUpdateRequired,
              extra: {'phoneNumber': phone},
            );
          } catch (_) {
            Get.offAllNamed(
              Routes.PROFILE_UPDATE_REQUIRED,
              arguments: {'phoneNumber': phone.toString()},
            );
          }
        }
      } else {
        state = state.copyWith(
          status: ApiCallStatus.error,
          errorMessage: res.message ?? 'রেজিস্ট্রেশন সম্পন্ন করা সম্ভব হয়নি।',
        );
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'Invalid Credential',
          message: res.message ?? 'রেজিস্ট্রেশন সম্পন্ন করা সম্ভব হয়নি।',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: ApiCallStatus.error,
        errorMessage: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  Future<void> loginWithOtp(String phone, BuildContext context) async {
    if (state.otp.trim().length < 6) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Please Fill the pin',
        message: 'OTP must be 6 digits.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, status: ApiCallStatus.loading);

    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final res = await loginUseCase(
        phone: phone,
        otp: state.otp.trim(),
      );

      state = state.copyWith(isLoading: false);

      if (res.status) {
        state = state.copyWith(status: ApiCallStatus.success);
        CustomSnackBar.showCustomToast(
          message: res.message ?? "লগইন সফল হয়েছে!",
        );
        if (Get.isRegistered<NavbarController>()) {
          Get.find<NavbarController>().getMeProfileInfo();
        }

        if (context.mounted) {
          try {
            context.go(AppRoutePaths.navBar);
          } catch (_) {
            Get.offAllNamed(Routes.NAVBAR);
          }
        }
      } else {
        state = state.copyWith(
          status: ApiCallStatus.error,
          errorMessage: res.message ?? 'লগইন ব্যর্থ হয়েছে। দয়া করে আবার চেষ্টা করুন।',
        );
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'Login Failed',
          message: res.message ?? 'লগইন ব্যর্থ হয়েছে। দয়া করে আবার চেষ্টা করুন।',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: ApiCallStatus.error,
        errorMessage: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Login Failed',
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি। দয়া করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন।',
      );
    }
  }
}

final verifyOtpNotifierProvider =
    NotifierProvider<VerifyOtpNotifier, VerifyOtpState>(VerifyOtpNotifier.new);
