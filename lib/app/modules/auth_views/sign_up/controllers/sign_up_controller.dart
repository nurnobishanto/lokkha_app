import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/data/repositories/auth_repository.dart';

import '../../../../components/custom_snackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/api_call_status.dart';

class SignUpController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  bool isLoading = false;

  Future<void> checkPhoneNumber() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 11) {
      _showErrorSnackBar("সঠিক ১১ ডিজিটের ফোন নম্বর প্রদান করুন।");
      return;
    }

    _setLoadingState(true);

    try {
      final res = await _authRepository.checkPhone(phone);
      _setLoadingState(false);

      if (res.status) {
        apiCallStatus = ApiCallStatus.success;
        final raw = res.rawData;
        final page = raw?["page"]?.toString().toLowerCase();
        
        final isOtp = page == "otp" || !res.isRegistered;

        if (isOtp) {
          Get.toNamed(Routes.VERIFY_OTP, arguments: {
            'phoneNumber': phone,
            'type': raw?["type"] ?? 'Registration',
          });
        } else {
          Get.toNamed(
            Routes.SIGNIN,
            arguments: {
              'phoneNumber': raw?['phone'] ?? raw?['data']?['phone'] ?? phone,
              'type': raw?['method'] ?? 'password',
            },
          );
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
