import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class ProfileUpdateController extends GetxController {
  final UpdateProfileUseCase _updateProfileUseCase =
      UpdateProfileUseCase(repository: ProfileRepository());
  final ChangePasswordUseCase _changePasswordUseCase =
      ChangePasswordUseCase(repository: ProfileRepository());

  RxString gender = 'অন্যান্য'.obs;
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;

  // Controllers
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController organizationController;
  late final TextEditingController occupationController;
  final currentPwdController = TextEditingController();
  final pwdController = TextEditingController();
  final confirmPwdController = TextEditingController();

  // Date of Birth
  RxString dob = ''.obs;

  // Image Pick & Crop
  RxBool pickedProfileImage = false.obs;
  Rx<XFile?> pickedImage = Rx<XFile?>(null);
  Rx<CroppedFile?> croppedImage = Rx<CroppedFile?>(null);
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();

  String genderSelect() {
    final map = {
      'পুরুষ': 'male',
      'মহিলা': 'female',
      'অন্যান্য': 'other',
    };
    return map[gender.value] ?? 'other';
  }

  void setGenderFromEnglishKey(String key) {
    final reverseMap = {
      'male': 'পুরুষ',
      'female': 'মহিলা',
      'other': 'অন্যান্য',
      'others': 'অন্যান্য',
    };
    gender.value = reverseMap[key.toLowerCase()] ?? 'অন্যান্য';
  }

  @override
  void onInit() {
    super.onInit();
    final user = myUser;
    nameController = TextEditingController(text: user.name ?? '');
    emailController = TextEditingController(text: user.email ?? '');
    organizationController = TextEditingController(text: user.organization ?? '');
    occupationController = TextEditingController(text: user.occupation ?? '');
    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      dob.value = user.dateOfBirth!.split("T").first.split(" ").first;
    }
    if (user.gender != null && user.gender!.isNotEmpty) {
      setGenderFromEnglishKey(user.gender!);
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dob.value = picked.toIso8601String().split("T").first;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage.value = pickedFile;
      _cropImage(pickedImage.value!.path);
    }
  }

  Future<void> _cropImage(String path) async {
    final croppedFile = await _imageCropper.cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          statusBarColor: LightThemeColors.primaryColor,
          toolbarColor: LightThemeColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          cropGridColor: LightThemeColors.primaryColor,
          cropFrameColor: LightThemeColors.primaryColor,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      croppedImage.value = croppedFile;
      pickedProfileImage.value = true;
    }
  }

  Future<void> updateProfileInfo(BuildContext context) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "নাম আবশ্যক",
        message: "আপনার নাম প্রদান করা বাধ্যতামূলক। অনুগ্রহ করে সঠিকভাবে লিখুন।",
      );
      return;
    }

    _isLoading.value = true;
    apiCallStatus = ApiCallStatus.loading;
    update();

    try {
      File? photoFile;
      if (croppedImage.value != null) {
        photoFile = File(croppedImage.value!.path);
      }

      final res = await _updateProfileUseCase(
        name: name,
        email: emailController.text.trim(),
        gender: genderSelect(),
        dateOfBirth: dob.value.trim().isNotEmpty ? dob.value.trim() : null,
        occupation: occupationController.text.trim(),
        organization: organizationController.text.trim(),
        photoFile: photoFile,
      );

      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        // If password was also entered
        if (pwdController.text.trim().isNotEmpty) {
          if (currentPwdController.text.trim().isEmpty) {
            CustomSnackBar.showCustomErrorSnackBar(
              title: "পাসওয়ার্ড পরিবর্তন",
              message: "পাসওয়ার্ড পরিবর্তন করতে বর্তমান পাসওয়ার্ড প্রদান করুন।",
            );
          } else if (pwdController.text.trim() != confirmPwdController.text.trim()) {
            CustomSnackBar.showCustomErrorSnackBar(
              title: "পাসওয়ার্ড মিলছে না",
              message: "পাসওয়ার্ড এবং নিশ্চিতকরণ পাসওয়ার্ড এক হতে হবে।",
            );
          } else {
            await _changePasswordUseCase(
              currentPassword: currentPwdController.text.trim(),
              newPassword: pwdController.text.trim(),
              confirmPassword: confirmPwdController.text.trim(),
            );
          }
        }

        CustomSnackBar.showCustomToast(
          message: res['message']?.toString() ?? "প্রোফাইল সফলভাবে আপডেট হয়েছে!",
        );

        if (Get.isRegistered<NavbarController>()) {
          Get.find<NavbarController>().getMeProfileInfo();
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfileData();
        }

        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "আপডেট ব্যর্থ",
          message: res['message']?.toString() ?? "প্রোফাইল আপডেট সম্পন্ন করা সম্ভব হয়নি।",
        );
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
      CustomSnackBar.showCustomErrorSnackBar(
        title: "ত্রুটি",
        message: "সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।",
      );
    } finally {
      _isLoading.value = false;
      apiCallStatus = ApiCallStatus.holding;
      update();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    organizationController.dispose();
    occupationController.dispose();
    currentPwdController.dispose();
    pwdController.dispose();
    confirmPwdController.dispose();
    super.onClose();
  }
}
