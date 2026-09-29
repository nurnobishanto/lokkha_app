import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/features/profile/profile.dart';

class ProfileUpdateController extends GetxController {
  RxString gender = 'অন্যান্য'.obs;

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
    };

    gender.value = reverseMap[key.toLowerCase()] ?? 'অন্যান্য';
  }

  @override
  void onInit() {
    setGenderFromEnglishKey(
        Get.find<NavbarController>().profileDataModel.value!.user?.gender ??
            'others');
    super.onInit();
  }

  //var groupValue = "a";
  final RxBool _isLoading = false.obs;
  RxObjectMixin<ProfileUpdateModel> model = ProfileUpdateModel().obs;

  /// Controllers
  final nameController = TextEditingController(
      text: Get.find<NavbarController>().profileDataModel.value!.user?.name ??
          '');
  final emailController = TextEditingController(
      text: Get.find<NavbarController>().profileDataModel.value!.user!.email ??
          '');
  final organizationController = TextEditingController(
    text: Get.find<NavbarController>()
            .profileDataModel
            .value!
            .user!
            .organization ??
        '',
  );
  final occupationController = TextEditingController(
    text:
        Get.find<NavbarController>().profileDataModel.value!.user!.occupation ??
            '',
  );
  final pwdController = TextEditingController();
  final confirmPwdController = TextEditingController();

  /// Date value using obs
  RxString dob = ''.obs;

  /// Date Picker Function
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

  @override
  void onClose() {
    nameController.dispose();
    pwdController.dispose();
    organizationController.dispose();
    occupationController.dispose();
    confirmPwdController.dispose();
    super.onClose();
  }

  /// Image pick
  RxBool pickedProfileImage = false.obs;
  Rx<XFile?> pickedImage = Rx<XFile?>(null);
  Rx<CroppedFile?> croppedImage = Rx<CroppedFile?>(null);
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage.value = pickedFile;
      _cropImage(pickedImage.value!.path);
    }
  }

  Future<void> _cropImage(String path) async {
    if (pickedImage.value != null) {
      final croppedFile = await _imageCropper.cropImage(
        sourcePath: pickedImage.value!.path,
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
              // CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        croppedImage.value = croppedFile;
        pickedProfileImage.value = true;
      }
    }
  }

  /// Method
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  Future<void> updateProfileInfo(context) async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "নাম আবশ্যক",
        message:
            "আপনার নাম প্রদান করা বাধ্যতামূলক। অনুগ্রহ করে সঠিকভাবে লিখুন।",
      );
      return;
    }
    if (dob.value.trim().isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "জন্ম তারিখ প্রয়োজন",
        message: "অনুগ্রহ করে আপনার জন্ম তারিখ নির্বাচন করুন।",
      );
      return;
    }

    if (gender.value.trim().isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "লিঙ্গ নির্বাচন করুন",
        message: "অনুগ্রহ করে আপনার লিঙ্গ নির্বাচন করুন।",
      );
      return;
    }

    if (occupationController.text.trim().isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "পেশা প্রয়োজন",
        message: "অনুগ্রহ করে আপনার পেশা লিখুন।",
      );
      return;
    }

    if (organizationController.text.trim().isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "প্রতিষ্ঠানের নাম প্রয়োজন",
        message: "আপনার প্রতিষ্ঠানের নাম লিখুন।",
      );
      return;
    }

    // যদি পাসওয়ার্ড দেওয়া হয়, তাহলে কনফার্মেশন চেক করতে হবে
    if (pwdController.text.trim().isNotEmpty ||
        confirmPwdController.text.trim().isNotEmpty) {
      if (pwdController.text.trim().length < 6) {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "পাসওয়ার্ড ত্রুটি",
          message: "পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।",
        );
        return;
      }

      if (pwdController.text.trim() != confirmPwdController.text.trim()) {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "পাসওয়ার্ড মিলছে না",
          message: "পাসওয়ার্ড এবং নিশ্চিতকরণ পাসওয়ার্ড এক হতে হবে।",
        );
        return;
      }
    }
    _isLoading.value = true;
    String? token = MySharedPref.getUserToken();
    if (token == "" && token.isEmpty) {
      return;
    }
    //

    dio.MultipartFile? imageMultipart;

    if (croppedImage.value != null) {
      XFile xFile = XFile(croppedImage.value!.path);
      imageMultipart = await dio.MultipartFile.fromFile(
        xFile.path,
        filename: nameController.text.trim(),
      );
    }
    String url = AppConstants.updateProfileInfo;

    dio.FormData data = dio.FormData.fromMap({
      if (nameController.text.trim().isNotEmpty)
        'name': nameController.text.trim(),
      if (emailController.text.trim().isNotEmpty)
        'email': emailController.text.trim(),
      if (occupationController.text.trim().isNotEmpty)
        'occupation': occupationController.text.trim(),
      if (organizationController.text.trim().isNotEmpty)
        'organization': organizationController.text.trim(),
      if (genderSelect().toString().isNotEmpty)
        'gender': genderSelect().toString(),
      if (dob.value.toString().isNotEmpty)
        'date_of_birth': dob.value.toString(),
      if (pwdController.text.trim().isNotEmpty)
        'password': pwdController.text.trim(),
      if (confirmPwdController.text.trim().isNotEmpty)
        'password_confirmation': confirmPwdController.text.trim(),
      if (imageMultipart != null) 'image': imageMultipart,
    });

    Map<String, dynamic> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    await BaseClient.safeApiCall(
      url,
      RequestType.post,
      headers: headers,
      data: data,
      onSuccess: (response) {
        apiCallStatus = ApiCallStatus.success;
        if (response.data['status']) {
          _isLoading.value = false;
          ProfileUpdateModel profileData =
              ProfileUpdateModel.fromJson(response.data);
          model.value = profileData;

          CustomSnackBar.showCustomToast(message: response.data['message']);
          Get.find<NavbarController>().getMeProfileInfo();

          Navigator.pop(context);
        } else {
          CustomSnackBar.showCustomSnackBar(
            title: "Something Went Wrong!",
            message: (response.data["message"].toString()),
          );
        }
      },
      onLoading: () {
        apiCallStatus = ApiCallStatus.loading;
        update();
        debugPrint("Logging...");
      },
      onError: (error) {
        apiCallStatus = ApiCallStatus.error;
        if (error.response?.data['errors'] != null) {
          final errors = error.response!.data['errors'];
          errors.forEach((key, value) {
            CustomSnackBar.showCustomErrorToast(
              message: value[0],
            );
          });
        } else {
          CustomSnackBar.showCustomToast(
            message: error.message,
          );
        }
      },
    );
  }
}
