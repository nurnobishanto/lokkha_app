import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/auth/auth.dart';

import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/navigation/navigation.dart';

class VerifyOtpController extends GetxController {
  String? otp;
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  bool isLoading = false;
  final AuthRepository _authRepository = AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSourceImpl());

  @override
  void onInit() {
    super.onInit();
    final phoneNumber = Get.arguments?['phoneNumber']?.toString() ?? '';
    final type = Get.arguments?['type']?.toString();
    if (phoneNumber.isNotEmpty) {
      sendOtp(phoneNumber, type);
    }
  }

  void setOtp(String value) {
    otp = value;
    update();
  }

  /// Register method via OTP
  Future<void> register(String phone) async {
    if (otp == null || otp!.trim().length < 6) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Please Fill the pin',
        message: 'OTP must be 6 digits.',
      );
      return;
    }

    _setLoadingState(true);

    try {
      final res = await _authRepository.register(
        phone: phone,
        otp: otp!.trim(),
      );

      _setLoadingState(false);

      if (res.status) {
        apiCallStatus = ApiCallStatus.success;
        CustomSnackBar.showCustomToast(
          message: res.message ?? "রেজিস্ট্রেশন সফল হয়েছে!",
        );
        if (Get.isRegistered<NavbarController>()) {
          Get.find<NavbarController>().getMeProfileInfo();
        }
        Get.offAllNamed(
          Routes.PROFILE_UPDATE_REQUIRED,
          arguments: {'phoneNumber': phone.toString()},
        );
      } else {
        apiCallStatus = ApiCallStatus.error;
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'Invalid Credential',
          message: res.message ?? 'রেজিস্ট্রেশন সম্পন্ন করা সম্ভব হয়নি।',
        );
      }
    } catch (e) {
      _setLoadingState(false);
      apiCallStatus = ApiCallStatus.error;
      debugPrint("Error Register: $e");
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
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

  /// Send OTP
  Future<void> sendOtp(String phone, [String? type]) async {
    apiCallStatus = ApiCallStatus.loading;
    update();

    try {
      final res = await _authRepository.sendOtp(phone);
      if (res.status) {
        apiCallStatus = ApiCallStatus.success;
        CustomSnackBar.showCustomToast(
          message: res.message ?? "ওটিপি সফলভাবে পাঠানো হয়েছে।",
        );
      } else {
        apiCallStatus = ApiCallStatus.error;
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'OTP Error',
          message: res.message ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে।',
        );
      }
    } catch (e) {
      apiCallStatus = ApiCallStatus.error;
      debugPrint("Error send otp: $e");
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'OTP Error',
        message: 'ওটিপি পাঠাতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
      );
    } finally {
      update();
    }
  }
}
