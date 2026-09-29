import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/services/storage/my_get_storage.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/constants/app_strings.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/routes/routes.dart';

///GLOBAL CONFIG: shared across the entire app.

/// App Info
String appName = AppStrings.appName;
RxString appVersion = ''.obs;
RxString appVersionCode = ''.obs;
RxString appPackage = ''.obs;
String appAuthor = "Techyfo";

/// Environment
bool isDebugMode = true;
bool isProduction = false;
bool enableLogging = true;

///  API & Headers
Map<String, String> defaultHeaders = {
  "Content-Type": "application/json",
  "Accept": "application/json",
};

///  Authentication / User Info (Reactive)
RxString? currentUserId = ''.obs;
RxString? userName = ''.obs;
RxString? userEmail = ''.obs;
RxString? userPhone = ''.obs;
RxString? userRole = ''.obs;
RxBool isLoggedIn = false.obs;
RxBool havePackage = false.obs;
RxInt unReadNotificationCount = 0.obs;


/// ✅ Device Info
String? deviceId;
String? deviceOS;
String? deviceBrand;
String? deviceModel;
//Size? screenSize;

/// ✅ Theme Settings
RxBool isDarkMode = false.obs;
Rx<ThemeMode> currentThemeMode = ThemeMode.system.obs;
Color primaryColor = Colors.blue;

/// ✅ Feature Toggles
RxBool isNewFeatureEnabled = true.obs;
RxBool isMaintenanceMode = false.obs;

/// ✅ Flags / App State
RxBool isLoading = false.obs;
RxBool hasNetwork = true.obs;
RxBool showIntro = true.obs;
RxBool isKeyboardOpen = false.obs;

/// ✅ UI & Layout
double defaultPaddingHorizontal = 8.0.w;
double defaultRadius = 12.0;
EdgeInsets defaultMargin = EdgeInsets.all(8.0.r);

/// File & Media
RxString? imageUploadPath = ''.obs;
RxString? downloadedFilePath = ''.obs;
List<String> supportedImageTypes = ["jpg", "png", "jpeg"];

///  Helper Methods

void printAppInfo() {
  if (!enableLogging) return;
  debugPrint("🧾 App Info:");
  debugPrint("📱 $appName v$appVersion by $appAuthor");
  debugPrint("🌐 API: ${AppConstants.baseUrl}");
  debugPrint("🔧 Debug: $isDebugMode");
  debugPrint("👤 Logged In: ${isLoggedIn.value}");
}

void clearAuth() {
  currentUserId?.value = '';
  isLoggedIn.value = false;
  logInfo("🚪 Logged Out");
}

void toggleThemeMode() {
  isDarkMode.value = !isDarkMode.value;
  currentThemeMode.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  logInfo("🎨 Theme: ${isDarkMode.value ? 'Dark' : 'Light'}");
}

void setDeviceInfo({
  required String id,
  required String os,
  required String brand,
  required String model,
  // required Size size,
}) {
  deviceId = id;
  deviceOS = os;
  deviceBrand = brand;
  deviceModel = model;
  //screenSize = size;
  logInfo("📱 Device Set: $deviceBrand $deviceModel");
}

void updateKeyboardStatus(bool isOpen) {
  isKeyboardOpen.value = isOpen;
  logInfo("⌨️ Keyboard: ${isOpen ? 'Open' : 'Closed'}");
}

/// ✅ Logging Utility
void logInfo(String message) {
  if (enableLogging && isDebugMode) {
    debugPrint("ℹ️ $message");
  }
}

void logError(String error) {
  if (enableLogging) {
    debugPrint("❌ $error");
  }
}

///  Misc Utility
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool isImageFile(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();
  return supportedImageTypes.contains(ext);
}

Future<void> fetchAppVersion() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appVersion.value = packageInfo.version;
  appPackage.value = packageInfo.packageName;
  appVersionCode.value = packageInfo.buildNumber;
}

Future<String?> getDeviceId() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Unique Android ID
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor; // Unique iOS ID
  }
  return null;
}

String convertDaysToHumanReadable(int days) {
  int years = days ~/ 365;
  int months = (days % 365) ~/ 30;
  int remainingDays = days % 365 % 30;

  List<String> result = [];

  if (years > 0) {
    result.add('$years বছর');
  }
  if (months > 0) {
    result.add('$months মাস');
  }
  if (remainingDays > 0 || result.isEmpty) {
    result.add('$remainingDays দিন');
  }

  return result.join(' ');
}

Widget isCheckedGifImage(String imageUrl) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: BoxFit.fitWidth,
    height: 110.0.h,
    width: double.infinity,
    placeholder: (context, url) =>
        const Center(child: CircularProgressIndicator()),
    errorWidget: (context, url, error) => Text("data")
  );
}

User myUser = MyGetStorage.readCache(MyGetStorage.meUser) ?? User();

class NameAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const NameAvatar({super.key, required this.name, this.radius = 26.0});

  // Function to get initials (e.g. "Safi Sadman" → "SS")
  String getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // Function to generate random background color
  Color generateAvatarColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      70 + random.nextInt(110), // R: 70–180
      70 + random.nextInt(110), // G: 70–180
      70 + random.nextInt(110), // B: 70–180
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = getInitials(name);
    final bgColor = generateAvatarColor();

    return CircleAvatar(
      radius: 26,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Widget buildAvatar(User user, {double radius = 26.0}) {
  if (user.image != null && user.image!.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(AppConstants.storageUrl + user.image!),
    );
  } else if (user.avatar != null && user.avatar!.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(user.avatar!),
    );
  } else {
    return NameAvatar(name: user.name.toString(), radius: radius);
  }
}

Future<void> openAppOrWebView(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    Get.to(BaseWebView(url: url, title: ''));
  }
}

bool isAppRoute(String path) {
  return {
    Routes.HOME,
    Routes.SPLASH,
    Routes.NAVBAR,
    Routes.QUESTION_BANK,
    Routes.CONTEST,
    Routes.BLOG,
    Routes.PROFILE,
    Routes.MOCK_TEST,
    Routes.AJKER_PORIKKHA,
    Routes.JOBS_UPDATE,
    Routes.AJKER_BISSHO,
    Routes.NOTICE_BOARD,
    Routes.SIGNIN,
    Routes.TERMS_CONDITION,
    Routes.ONBOARDING,
    Routes.VERIFY_OTP,
    Routes.FORGET_PASSWORD,
    Routes.SIGN_UP,
    Routes.AUTH_GATEWAY,
    Routes.PROFILE_UPDATE,
    Routes.PROFILE_HISTORY,
    Routes.PROFILE_UPDATE_REQUIRED,
    Routes.MOCK_TEST_TAB,
    Routes.FAST_PRACTICE,
    Routes.TOPIC_SELECTION,
    Routes.JOBS,
    Routes.CURRENT_AFFAIRS,
    Routes.PREMIUM_PACKAGES,
    Routes.MY_APP,
    Routes.SUBJECT_SECTION,
    Routes.MY_PACKAGES,
    Routes.MY_ORDERS,
    Routes.LATEST_EXAM,
    Routes.MAINTENANCE_MODE_VIEW,
    Routes.APP_UPDATE_VIEW,
    Routes.ALL_CONTEST,
    Routes.SPONSOR_ADS,
    Routes.VOCABULARY,
    Routes.MODEL_TEST,
    Routes.LECTURE_SHEET,
    Routes.SHEET_DETAILS,
    Routes.MODEL_TEST_CATEGORIES,
    Routes.MODEL_TEST_DETAILS,
    Routes.EXAM_CATEGORY,
    Routes.EXAM_CATEGORY_DETAILS,
    Routes.COURSES,
    Routes.COURSE_DETAILS,
    Routes.COURSE_LEARN,
    Routes.COURSE_CHECKOUT,
    Routes.ALL_COURSES,
    Routes.ALL_EXAM,
    Routes.JOB_DETAILS,
  }.contains(path);
}
