import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/auth/auth.dart';

import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/navigation/navigation.dart';

class SignInController extends GetxController {
  bool isRegister = false;
  bool isLoading = false;
  final TextEditingController passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSourceImpl());
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;

  /// Login method (supports password and otp login)
  Future<void> login(String phone, String type, String password) async {
    _setLoadingState(true);

    try {
      final isOtpLogin = type.toLowerCase() == 'otp';
      final res = isOtpLogin
          ? await _authRepository.login(phone: phone, otp: password)
          : await _authRepository.login(phone: phone, password: password);

      _setLoadingState(false);

      if (res.status) {
        apiCallStatus = ApiCallStatus.success;
        CustomSnackBar.showCustomToast(
          message: res.message ?? "লগইন সফল হয়েছে!",
        );

        if (Get.isRegistered<NavbarController>()) {
          Get.find<NavbarController>().getMeProfileInfo();
        }
        Get.offAllNamed(Routes.NAVBAR);
      } else {
        apiCallStatus = ApiCallStatus.error;
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'Login Failed',
          message: res.message ?? 'লগইন ব্যর্থ হয়েছে। দয়া করে আবার চেষ্টা করুন।',
        );
      }
    } catch (e) {
      _setLoadingState(false);
      apiCallStatus = ApiCallStatus.error;
      debugPrint("Error login: $e");
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Login Failed',
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি। দয়া করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন।',
      );
    } finally {
      update();
    }
  }

  void _setLoadingState(bool loading) {
    isLoading = loading;
    apiCallStatus = loading ? ApiCallStatus.loading : ApiCallStatus.holding;
    update();
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}
