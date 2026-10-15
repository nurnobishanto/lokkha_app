import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/utils/phone_utils.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class ForgetPasswordState {
  final String phone;
  final bool isLoading;
  final String? errorMessage;
  final String? otp;
  final int expiresIn;

  const ForgetPasswordState({
    this.phone = '',
    this.isLoading = false,
    this.errorMessage,
    this.otp,
    this.expiresIn = 300,
  });

  ForgetPasswordState copyWith({
    String? phone,
    bool? isLoading,
    String? errorMessage,
    String? otp,
    int? expiresIn,
  }) {
    return ForgetPasswordState(
      phone: phone ?? this.phone,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      otp: otp ?? this.otp,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }
}

class ForgetPasswordNotifier extends Notifier<ForgetPasswordState> {
  @override
  ForgetPasswordState build() => const ForgetPasswordState();

  void setPhone(String phone) {
    state = state.copyWith(phone: phone, errorMessage: null);
  }

  Future<void> sendOtp({
    required BuildContext context,
    String? phoneOverride,
  }) async {
    final rawPhone = (phoneOverride ?? state.phone).trim();
    final cleanPhone = PhoneUtils.toLocal11Digit(rawPhone).isNotEmpty
        ? PhoneUtils.toLocal11Digit(rawPhone)
        : PhoneUtils.sanitize(rawPhone);

    if (cleanPhone.length != 11) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'ভুল নম্বর',
        message: 'দয়া করে একটি সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন।',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
      final res = await forgotPasswordUseCase(cleanPhone);

      final newExpiresIn = res.expiresIn ?? 300;
      state = state.copyWith(
        isLoading: false,
        otp: res.otp,
        expiresIn: newExpiresIn,
      );

      if (res.status) {
        CustomSnackBar.showCustomToast(
          message: res.message ?? 'ওটিপি সফলভাবে পাঠানো হয়েছে।',
        );

        if (context.mounted) {
          context.push(
            Routes.verifyOtp,
            extra: {
              'phoneNumber': cleanPhone,
              'type': 'ForgotPassword',
              'initialExpiresIn': newExpiresIn,
              'autoSendOtp': false,
              'serverOtp': res.otp,
              'otp': res.otp,
            },
          );
        }
      } else {
        state = state.copyWith(
          errorMessage: res.message ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে।',
        );
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'ব্যর্থ হয়েছে',
          message: res.message ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে। আবার চেষ্টা করুন।',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি। দয়া করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন।',
      );
    }
  }
}

final forgetPasswordNotifierProvider =
    NotifierProvider<ForgetPasswordNotifier, ForgetPasswordState>(
  ForgetPasswordNotifier.new,
);
