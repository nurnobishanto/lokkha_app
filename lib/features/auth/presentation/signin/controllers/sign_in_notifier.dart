import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class SignInState {
  final bool isLoading;
  final ApiCallStatus status;
  final String? errorMessage;

  const SignInState({
    this.isLoading = false,
    this.status = ApiCallStatus.holding,
    this.errorMessage,
  });

  SignInState copyWith({
    bool? isLoading,
    ApiCallStatus? status,
    String? errorMessage,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SignInNotifier extends Notifier<SignInState> {
  @override
  SignInState build() => const SignInState();

  Future<void> login({
    required String phone,
    required String type,
    required String password,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, status: ApiCallStatus.loading);

    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final isOtpLogin = type.toLowerCase() == 'otp';
      final res = isOtpLogin
          ? await loginUseCase(phone: phone, otp: password)
          : await loginUseCase(phone: phone, password: password);

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
            context.go(Routes.navbar);
          } catch (_) {
            Get.offAllNamed(Routes.navbar);
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

final signInNotifierProvider =
    NotifierProvider<SignInNotifier, SignInState>(SignInNotifier.new);
