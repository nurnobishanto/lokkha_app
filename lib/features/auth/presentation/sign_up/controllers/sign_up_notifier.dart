import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class SignUpState {
  final bool isLoading;
  final String? errorMessage;

  const SignUpState({
    this.isLoading = false,
    this.errorMessage,
  });

  SignUpState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SignUpNotifier extends Notifier<SignUpState> {
  @override
  SignUpState build() => const SignUpState();

  Future<void> checkPhoneNumber(String rawPhone, BuildContext context) async {
    final phone = rawPhone.trim();
    if (phone.isEmpty || phone.length < 10) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "সতর্কতা",
        message: "সঠিক ফোন নম্বর প্রদান করুন।",
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final checkPhoneUseCase = ref.read(checkPhoneUseCaseProvider);
      final res = await checkPhoneUseCase(phone);
      state = state.copyWith(isLoading: false);

      if (res.status) {
        final targetPhone = res.canonicalPhone ?? phone;
        final isRegistration = !res.isRegistered || res.suggestedStep == 'register';

        if (context.mounted) {
          if (isRegistration) {
            _navigateToOtp(context, targetPhone, 'Registration');
          } else {
            if (res.authMethod == 'otp' || res.suggestedStep == 'otp') {
              _navigateToOtp(context, targetPhone, 'Login');
            } else {
              _navigateToSignIn(context, targetPhone, res.authMethod ?? 'password');
            }
          }
        }
      } else {
        state = state.copyWith(
          errorMessage: res.message ?? "ফোন নম্বরটি যাচাই করা সম্ভব হয়নি।",
        );
        CustomSnackBar.showCustomErrorSnackBar(
          title: "সতর্কতা",
          message: res.message ?? "ফোন নম্বরটি যাচাই করা সম্ভব হয়নি।",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।",
      );
      CustomSnackBar.showCustomErrorSnackBar(
        title: "সতর্কতা",
        message: "সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।",
      );
    }
  }

  void _navigateToOtp(BuildContext context, String phone, String type) {
    context.push(
      Routes.verifyOtp,
      extra: {'phoneNumber': phone, 'type': type},
    );
  }

  void _navigateToSignIn(BuildContext context, String phone, String authMethod) {
    context.push(
      Routes.signIn,
      extra: {'phoneNumber': phone, 'type': authMethod},
    );
  }
}

final signUpNotifierProvider =
    NotifierProvider<SignUpNotifier, SignUpState>(SignUpNotifier.new);
