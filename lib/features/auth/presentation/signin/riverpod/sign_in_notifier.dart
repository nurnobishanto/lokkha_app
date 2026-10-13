import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/features/navigation/presentation/riverpod/navbar_notifier.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class SignInState {
  final bool isLoading;
  final String? errorMessage;

  const SignInState({
    this.isLoading = false,
    this.errorMessage,
  });

  SignInState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final isOtpLogin = type.toLowerCase() == 'otp';
      final res = await loginUseCase(
        phone: phone,
        type: isOtpLogin ? 'otp' : 'password',
        password: isOtpLogin ? null : password,
        otp: isOtpLogin ? password : null,
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
        final errorMsg =
            res.message ?? 'লগইন ব্যর্থ হয়েছে। দয়া করে আবার চেষ্টা করুন।';
        state = state.copyWith(errorMessage: errorMsg);
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'Login Failed',
          message: errorMsg,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Login Failed',
        message:
            'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি। দয়া করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন।',
      );
    }
  }
}

final signInNotifierProvider =
    NotifierProvider<SignInNotifier, SignInState>(SignInNotifier.new);
