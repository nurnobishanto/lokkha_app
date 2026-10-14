import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/features/navigation/presentation/riverpod/navbar_notifier.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class VerifyOtpState {
  final bool isLoading;
  final String otp;
  final String? errorMessage;
  final int expiresIn;

  const VerifyOtpState({
    this.isLoading = false,
    this.otp = '',
    this.errorMessage,
    this.expiresIn = 300,
  });

  VerifyOtpState copyWith({
    bool? isLoading,
    String? otp,
    String? errorMessage,
    int? expiresIn,
  }) {
    return VerifyOtpState(
      isLoading: isLoading ?? this.isLoading,
      otp: otp ?? this.otp,
      errorMessage: errorMessage ?? this.errorMessage,
      expiresIn: expiresIn ?? this.expiresIn,
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final sendOtpUseCase = ref.read(sendOtpUseCaseProvider);
      final res = await sendOtpUseCase(phone, type: type);
      final newExpiresIn = res.expiresIn ?? 300;
      state = state.copyWith(isLoading: false, expiresIn: newExpiresIn);
      if (res.status) {
        CustomSnackBar.showCustomToast(
          message: res.message ?? "ওটিপি সফলভাবে পাঠানো হয়েছে।",
        );
      } else {
        state = state.copyWith(
          errorMessage: res.message ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে।',
        );
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'OTP Error',
          message: res.message ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে।',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
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

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final registerUseCase = ref.read(registerUseCaseProvider);
      final res = await registerUseCase(
        phone: phone,
        otp: state.otp.trim(),
      );

      state = state.copyWith(isLoading: false);

      if (res.status) {
        CustomSnackBar.showCustomToast(
          message: res.message ?? "রেজিস্ট্রেশন সফল হয়েছে!",
        );
        ref.read(navbarNotifierProvider.notifier).fetchProfileInfo();

        if (context.mounted) {
          context.go(
            Routes.profileUpdateRequired,
            extra: {'phoneNumber': phone},
          );
        }
      } else {
        state = state.copyWith(
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
        errorMessage: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  Future<void> verifyOtpForReset(String phone, BuildContext context) async {
    if (state.otp.trim().length < 6) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Please Fill the pin',
        message: 'OTP must be 6 digits.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final verifyOtpUseCase = ref.read(verifyOtpUseCaseProvider);
      final res = await verifyOtpUseCase(
        phone: phone,
        otp: state.otp.trim(),
      );

      state = state.copyWith(isLoading: false);

      if (res.status) {
        if (context.mounted) {
          context.push(
            Routes.resetPassword,
            extra: {
              'phoneNumber': phone,
              'otp': state.otp.trim(),
            },
          );
        }
      } else {
        state = state.copyWith(
          errorMessage: res.message ?? 'ওটিপি যাচাই করা সম্ভব হয়নি।',
        );
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'OTP Error',
          message: res.message ?? 'সঠিক ওটিপি প্রদান করুন।',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
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

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final res = await loginUseCase(
        phone: phone,
        type: 'otp',
        otp: state.otp.trim(),
      );

      state = state.copyWith(isLoading: false);

      if (res.status) {
        CustomSnackBar.showCustomToast(
          message: res.message ?? "লগইন সফল হয়েছে!",
        );
        ref.read(navbarNotifierProvider.notifier).fetchProfileInfo();

        if (context.mounted) {
          if (!res.profileCompleted) {
            context.go(
              Routes.profileUpdateRequired,
              extra: {'phoneNumber': phone},
            );
          } else {
            context.go(Routes.navbar);
          }
        }
      } else {
        state = state.copyWith(
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
