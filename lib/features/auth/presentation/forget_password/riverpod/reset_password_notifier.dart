import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/utils/phone_utils.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/features/auth/presentation/forget_password/widgets/password_reset_success_dialog.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class ResetPasswordState {
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ResetPasswordState({
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  bool get doPasswordsMatch =>
      confirmPassword.isEmpty || password == confirmPassword;

  bool get isValid =>
      password.isNotEmpty &&
      password.length >= 6 &&
      confirmPassword.isNotEmpty &&
      password == confirmPassword;

  ResetPasswordState copyWith({
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ResetPasswordState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ResetPasswordNotifier extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  void setPassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      errorMessage: null,
    );
  }

  Future<void> updatePassword({
    required String phone,
    required String otp,
    required BuildContext context,
  }) async {
    final cleanPhone = PhoneUtils.toLocal11Digit(phone).isNotEmpty
        ? PhoneUtils.toLocal11Digit(phone)
        : PhoneUtils.sanitize(phone);

    final password = state.password.trim();
    final confirmPassword = state.confirmPassword.trim();

    if (password.length < 6) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'দুর্বল পাসওয়ার্ড',
        message: 'পাসওয়ার্ডটি কমপক্ষে ৬ অক্ষরের হতে হবে।',
      );
      return;
    }

    if (password != confirmPassword) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'পাসওয়ার্ড মেলেনি',
        message: 'নতুন পাসওয়ার্ড এবং কনফার্ম পাসওয়ার্ড এক নয়।',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);
      final res = await resetPasswordUseCase(
        phone: cleanPhone,
        otp: otp.trim(),
        password: password,
        passwordConfirmation: confirmPassword,
      );

      state = state.copyWith(isLoading: false);

      if (res.status) {
        state = state.copyWith(isSuccess: true);
        CustomSnackBar.showCustomToast(
          message: res.message ?? 'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে।',
        );
        if (context.mounted) {
          PasswordResetSuccessDialog.show(context, phoneNumber: cleanPhone);
        }
      } else {
        state = state.copyWith(
          errorMessage: res.message ?? 'পাসওয়ার্ড রিসেট করা সম্ভব হয়নি।',
        );
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'রিসেট ব্যর্থ',
          message: res.message ?? 'পাসওয়ার্ড রিসেট করা সম্ভব হয়নি। আবার চেষ্টা করুন।',
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

final resetPasswordNotifierProvider =
    NotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
  ResetPasswordNotifier.new,
);
