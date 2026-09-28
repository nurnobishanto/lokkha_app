import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/data/network/api_client.dart';
import 'package:lokkha/utils/constants.dart';

import '../../../helper/global.dart';
import '../../../components/custom_snackbar.dart';
import '../../../routes/app_pages.dart';
import '../../../services/api_call_status.dart';
import '../../navbar/controllers/navbar_controller.dart';

class ProfileUpdateRequiredController extends GetxController {
  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final pwdController = TextEditingController();
  final confirmPwdController = TextEditingController();
  final dobController = TextEditingController();
  //final occupationController = TextEditingController();

  // Fields
  String gender = '';
  String occupation = '';
  bool isLoading = false;
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;

  void _setLoadingState(bool loading) {
    isLoading = loading;
    apiCallStatus = loading ? ApiCallStatus.loading : ApiCallStatus.holding;
    update();
  }

  /// Date Picker Function
  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = picked.toIso8601String().split("T").first;
    }
  }

  Future<void> updateProfileRequired() async {
    // Validation
    if (nameController.text.trim().isEmpty ||
        dobController.text.trim().isEmpty ||
        gender.trim().isEmpty ||
        occupation.trim().isEmpty ||
        pwdController.text.trim().isEmpty ||
        confirmPwdController.text.trim().isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Missing Information",
        message: "Please fill in all the required fields before continuing.",
      );
      return;
    }

    if (pwdController.text.trim() != confirmPwdController.text.trim()) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Oops!",
        message:
            "The password and confirmation password do not match.Please try again.",
      );
      return;
    }

    _setLoadingState(true);

    final Map<String, dynamic> data = {
      "name": nameController.text.trim(),
      "date_of_birth": dobController.text.trim(),
      "gender": gender.trim(),
      "phone": phoneController.text.trim().toString(),
      "occupation": occupation.trim(),
      "password": pwdController.text.trim(),
      "password_confirmation": confirmPwdController.text.trim(),
    };

    try {
      final response = await ApiClient.post(
        AppConstants.v1UserProfileUpdate,
        data: data,
      );

      _setLoadingState(false);
      apiCallStatus = ApiCallStatus.success;

      final isSuccess = response.data['status'] == true ||
          response.data['status'] == 1 ||
          response.data['success'] == true;

      if (isSuccess) {
        CustomSnackBar.showCustomToast(
          message: response.data["message"] ?? "প্রোফাইল সফলভাবে আপডেট হয়েছে!",
        );
        isLoggedIn.value = true;
        if (Get.isRegistered<NavbarController>()) {
          Get.find<NavbarController>().getMeProfileInfo();
        }
        Get.offAllNamed(Routes.NAVBAR);
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "Update Failed",
          message: response.data["message"] ?? "প্রোফাইল আপডেট করা যায়নি।",
        );
      }
    } on DioException catch (error) {
      _setLoadingState(false);
      apiCallStatus = ApiCallStatus.error;
      if (error.response?.data is Map && error.response?.data["errors"] != null) {
        final errors = error.response!.data['errors'];
        if (errors is Map) {
          errors.forEach((key, value) {
            CustomSnackBar.showCustomErrorToast(
              message: value is List ? value.first.toString() : value.toString(),
            );
          });
        }
      } else {
        CustomSnackBar.showCustomToast(
          message: error.message ?? "সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।",
        );
      }
    } catch (e) {
      _setLoadingState(false);
      apiCallStatus = ApiCallStatus.error;
      debugPrint("Error update Profile Info Required: $e");
      CustomSnackBar.showCustomErrorToast(message: "অপ্রত্যাশিত সমস্যা হয়েছে।");
    } finally {
      update();
    }
  }

  /// Submit Function
  void submit() {
    debugPrint("Name: ${nameController.text}");
    debugPrint("Phone: ${phoneController.text}");
    debugPrint("DOB: ${dobController.text}");
    debugPrint("Gender: $gender");
    debugPrint("Occupation: $occupation");
    debugPrint("Password: ${pwdController.text}");
    debugPrint("Confirm Password: ${confirmPwdController.text}");
  }

  /// Dispose all controllers
  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    pwdController.dispose();
    confirmPwdController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
