import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/services/storage/app_storage_cache.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/constants/app_strings.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lokkha/app/router/router.dart';

/// GLOBAL CONFIG: shared across the entire app.

/// App Info
String appName = AppStrings.appName;
final ValueNotifier<String> appVersion = ValueNotifier<String>('');
final ValueNotifier<String> appVersionCode = ValueNotifier<String>('');
final ValueNotifier<String> appPackage = ValueNotifier<String>('');
String appAuthor = "Techyfo";

/// Environment
bool isDebugMode = true;
bool isProduction = false;
bool enableLogging = true;

/// API & Headers
Map<String, String> defaultHeaders = {
  "Content-Type": "application/json",
  "Accept": "application/json",
};

/// Authentication / User Info (Standard Flutter ValueNotifier)
final ValueNotifier<String?> currentUserId = ValueNotifier<String?>('');
final ValueNotifier<String?> userName = ValueNotifier<String?>('');
final ValueNotifier<String?> userEmail = ValueNotifier<String?>('');
final ValueNotifier<String?> userPhone = ValueNotifier<String?>('');
final ValueNotifier<String?> userRole = ValueNotifier<String?>('');
final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
final ValueNotifier<bool> havePackage = ValueNotifier<bool>(false);
final ValueNotifier<int> unReadNotificationCount = ValueNotifier<int>(0);

/// Device Info
String? deviceId;
String? deviceOS;
String? deviceBrand;
String? deviceModel;
//Size? screenSize;

/// Theme Settings
final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);
final ValueNotifier<ThemeMode> currentThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
Color primaryColor = Colors.blue;

/// Feature Toggles
final ValueNotifier<bool> isNewFeatureEnabled = ValueNotifier<bool>(true);
final ValueNotifier<bool> isMaintenanceMode = ValueNotifier<bool>(false);

/// Flags / App State
final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
final ValueNotifier<bool> hasNetwork = ValueNotifier<bool>(true);
final ValueNotifier<bool> showIntro = ValueNotifier<bool>(true);
final ValueNotifier<bool> isKeyboardOpen = ValueNotifier<bool>(false);

/// UI & Layout
double defaultPaddingHorizontal = 8.0.w;
double defaultRadius = 12.0;
EdgeInsets defaultMargin = EdgeInsets.all(8.0.r);

/// File & Media
final ValueNotifier<String?> imageUploadPath = ValueNotifier<String?>('');
final ValueNotifier<String?> downloadedFilePath = ValueNotifier<String?>('');
List<String> supportedImageTypes = ["jpg", "png", "jpeg"];

/// Helper Methods

void printAppInfo() {
  if (!enableLogging) return;
  debugPrint("🧾 App Info:");
  debugPrint("📱 $appName v${appVersion.value} by $appAuthor");
  debugPrint("🌐 API: ${Endpoints.baseUrl}");
  debugPrint("🔧 Debug: $isDebugMode");
  debugPrint("👤 Logged In: ${isLoggedIn.value}");
}

void clearAuth() {
  currentUserId.value = '';
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
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
    }
    final first = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    final second = parts[1].isNotEmpty ? parts[1][0].toUpperCase() : '';
    final res = '$first$second';
    return res.isNotEmpty ? res : 'U';
  }

  // Function to generate deterministic background color
  Color generateAvatarColor() {
    final random = Random(name.hashCode);
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
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Widget buildAvatar(User user, {double radius = 26.0}) {
  final rawPath = user.photoUrl ?? user.avatar ?? user.image;
  final fullUrl = Endpoints.resolveUrl(rawPath);

  if (fullUrl.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: fullUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: SizedBox(
          width: radius * 0.7,
          height: radius * 0.7,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => NameAvatar(
        name: user.name ?? '',
        radius: radius,
      ),
    );
  } else {
    return NameAvatar(name: user.name ?? '', radius: radius);
  }
}

Future<void> openAppOrWebView(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).push(
        MaterialPageRoute(
          builder: (_) => BaseWebView(url: url, title: ''),
        ),
      );
    }
  }
}

bool isAppRoute(String path) {
  return {
    Routes.home,
    Routes.splash,
    Routes.navbar,
    Routes.questionBank,
    Routes.contest,
    Routes.blog,
    Routes.profile,
    Routes.mockTest,
    '/ajker-porikkha',
    '/jobs-update',
    '/ajker-bissho',
    '/notice-board',
    Routes.signIn,
    Routes.termsCondition,
    Routes.onBoarding,
    Routes.verifyOtp,
    Routes.forgetPassword,
    Routes.resetPassword,
    Routes.signUp,
    Routes.authGateway,
    Routes.profileUpdate,
    Routes.profileHistory,
    Routes.profileUpdateRequired,
    Routes.mockTestTab,
    Routes.fastPractice,
    Routes.topicSelection,
    Routes.jobs,
    Routes.currentAffairs,
    Routes.packages,
    Routes.packageDetails,
    Routes.myApp,
    Routes.subjectSection,
    Routes.myPackages,
    Routes.myOrders,
    Routes.latestExam,
    Routes.maintenanceMode,
    Routes.appUpdate,
    Routes.allContest,
    Routes.sponsorAds,
    Routes.vocabulary,
    '/model-test',
    Routes.lectureSheet,
    Routes.sheetDetails,
    '/model-test-categories',
    '/model-test-details',
    Routes.examCategory,
    Routes.examCategoryDetails,
    Routes.courses,
    Routes.courseDetails,
    Routes.courseLearn,
    Routes.courseCheckout,
    Routes.allCourses,
    Routes.allExam,
    Routes.jobDetails,
  }.contains(path);
}
