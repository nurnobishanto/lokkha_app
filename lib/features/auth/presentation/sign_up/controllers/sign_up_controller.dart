import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/auth/auth.dart';

import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/core/network/api_call_status.dart';

class SignUpController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final AuthRepository _authRepository = AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSourceImpl());
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  bool isLoading = false;

  Future<void> checkPhoneNumber() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      _showErrorSnackBar("সঠিক ফোন নম্বর প্রদান করুন।");
      return;
    }

    _setLoadingState(true);

    try {
      final res = await _authRepository.checkPhone(phone);
      _setLoadingState(false);

      if (res.status) {
        apiCallStatus = ApiCallStatus.success;
        final targetPhone = res.canonicalPhone ?? phone;
        final isRegistration = !res.isRegistered || res.suggestedStep == 'register';

        if (isRegistration) {
          Get.toNamed(Routes.VERIFY_OTP, arguments: {
            'phoneNumber': targetPhone,
            'type': 'Registration',
          });
        } else {
          if (res.authMethod == 'otp' || res.suggestedStep == 'otp') {
            Get.toNamed(Routes.VERIFY_OTP, arguments: {
              'phoneNumber': targetPhone,
              'type': 'Login',
            });
          } else {
            Get.toNamed(
              Routes.SIGNIN,
              arguments: {
                'phoneNumber': targetPhone,
                'type': res.authMethod ?? 'password',
              },
            );
          }
        }
      } else {
        apiCallStatus = ApiCallStatus.error;
        _showErrorSnackBar(res.message ?? "ফোন নম্বরটি যাচাই করা সম্ভব হয়নি।");
      }
    } catch (e) {
      _setLoadingState(false);
      apiCallStatus = ApiCallStatus.error;
      debugPrint("Error checking phone number: $e");
      _showErrorSnackBar("সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।");
    } finally {
      update();
    }
  }

  void _setLoadingState(bool loading) {
    isLoading = loading;
    apiCallStatus = loading ? ApiCallStatus.loading : ApiCallStatus.holding;
    update();
  }

  void _showErrorSnackBar(String message) {
    CustomSnackBar.showCustomErrorSnackBar(
      title: "সতর্কতা",
      message: message,
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
