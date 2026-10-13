import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/phone_utils.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/features/auth/data/models/auth_response_model.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class SignUpState {
  final bool isLoading;
  final String? errorMessage;
  final AuthResponseModel? response;

  const SignUpState({
    this.isLoading = false,
    this.errorMessage,
    this.response,
  });

  SignUpState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthResponseModel? response,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      response: response ?? this.response,
    );
  }
}

class SignUpNotifier extends Notifier<SignUpState> {
  @override
  SignUpState build() => const SignUpState();

  Future<void> checkPhoneNumber(String rawPhone, BuildContext context) async {
    final l10n = context.l10n;
    final sanitized = PhoneUtils.sanitize(rawPhone);

    if (sanitized.isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: l10n.warningTitle,
        message: l10n.providePhoneNumber,
      );
      return;
    }

    if (!PhoneUtils.isValidBdMobile(sanitized)) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: l10n.warningTitle,
        message: l10n.invalidPhoneNumber,
      );
      return;
    }

    final localPhone = PhoneUtils.toLocal11Digit(sanitized);

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final checkPhoneUseCase = ref.read(checkPhoneUseCaseProvider);
      final res = await checkPhoneUseCase(localPhone);
      state = state.copyWith(isLoading: false, response: res);

      if (res.status) {
        // Retrieve normalized phone number from API canonical data or fallback to local format
        final targetPhone = res.canonicalPhone ?? localPhone;
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
        final errorMsg = res.message ?? l10n.invalidPhoneNumber;
        state = state.copyWith(errorMessage: errorMsg);
        CustomSnackBar.showCustomErrorSnackBar(
          title: l10n.warningTitle,
          message: errorMsg,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
      CustomSnackBar.showCustomErrorSnackBar(
        title: l10n.warningTitle,
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি। অনুগ্রহ করে ইন্টারনেট সংযোগ পরীক্ষা করুন।',
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
