import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/app_system/data/datasources/app_system_remote_data_source.dart';
import 'package:lokkha/features/app_system/data/models/app_info_model.dart';
import 'package:lokkha/features/app_system/data/repositories/app_system_repository_impl.dart';
import 'package:lokkha/features/app_system/presentation/app_update/views/app_update_view_view.dart';
import 'package:lokkha/features/app_system/presentation/maintenance_mode/views/maintenance_mode_view_view.dart';
import 'package:lokkha/features/app_system/presentation/widgets/in_app_popup_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  /// Reactive state for dynamic app information & version check
  final Rx<AppInfoModel?> appInfo = Rx<AppInfoModel?>(null);
  final RxBool isChecking = false.obs;
  RxBool updateRequiredCheck = false.obs;
  RxBool firstAppUpdateCalled = false.obs;

  bool updateRequired = false;
  bool maintenanceMode = false;
  bool hasShownInAppPopup = false;

  Timer? _firstTimer;
  Timer? _timer;

  /// Starts the update & metadata service on app startup
  void startUpdateService() {
    stopUpdateService();
    fetchAppInfoAndCheckVersion();
  }

  void stopUpdateService() {
    _firstTimer?.cancel();
    _firstTimer = null;
    _timer?.cancel();
    _timer = null;
  }

  /// Fetches 100% dynamic app-info metadata & evaluates version check in a single call
  Future<AppInfoModel?> fetchAppInfoAndCheckVersion() async {
    String platform = 'android';
    if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    }

    if (appVersionCode.value.isEmpty) {
      try {
        await fetchAppVersion();
      } catch (_) {}
    }

    final code = appVersionCode.value.isNotEmpty ? appVersionCode.value : '31';

    try {
      isChecking.value = true;
      final repository = AppSystemRepositoryImpl(
        remoteDataSource: AppSystemRemoteDataSourceImpl(),
      );

      final result = await repository.getAppInfo(
        platform: platform,
        versionCode: code,
      );

      appInfo.value = result;

      // Update maintenance flag
      maintenanceMode = result.data.systemStatus.isUnderMaintenance ||
          (result.data.clientVersionCheck?.maintenanceMode == true);

      // Update force update flag
      updateRequired =
          result.data.clientVersionCheck?.updateRequired == true;

      updateRequiredCheck.value = updateRequired;
      isChecking.value = false;
      return result;
    } catch (e) {
      debugPrint('[AppUpdateService] Failed to fetch v1 app-info: $e');
      isChecking.value = false;
      return null;
    }
  }

  /// Handles navigation based on maintenance and version checks.
  /// Returns `true` if the app is allowed to proceed to normal navigation,
  /// or `false` if blocked by maintenance or force-update.
  bool handleStartupFlow() {
    final info = appInfo.value;
    if (info == null) return true;

    // 1. Maintenance Mode Check
    if (maintenanceMode) {
      debugPrint('[AppUpdateService] System under maintenance. Redirecting...');
      Get.offAll(
        () => MaintenanceModeView(
          title: info.data.systemStatus.maintenanceTitle,
          message: info.data.systemStatus.maintenanceMessage,
        ),
      );
      return false;
    }

    // 2. Force Update Check
    if (updateRequired) {
      final downloadUrlString = info.data.clientVersionCheck?.downloadUrl ??
          (Platform.isIOS
              ? info.data.downloads.appStoreUrl
              : info.data.downloads.googlePlayUrl);
      final downloadUri = Uri.tryParse(downloadUrlString) ??
          Uri.parse('https://play.google.com/store/apps/details?id=com.techyfo.lokkha');

      final latestName = info.data.clientVersionCheck?.latestVersionName.isNotEmpty == true
          ? info.data.clientVersionCheck!.latestVersionName
          : info.data.versions.android.latestVersionName;
      final subtitleMessage = latestName.isNotEmpty
          ? "নতুন ফিচার, উন্নত সেবা ও আরও ভালো অভিজ্ঞতার জন্য অনুগ্রহ করে অ্যাপটি আপডেট করে নিন।"
          : "নতুন ফিচার, উন্নত সেবা ও আরও ভালো অভিজ্ঞতার জন্য অনুগ্রহ করে অ্যাপটি আপডেট করে নিন।";

      final currentVer = appVersion.value.isNotEmpty
          ? appVersion.value
          : (info.data.clientVersionCheck?.currentVersion.isNotEmpty == true
              ? info.data.clientVersionCheck!.currentVersion
              : '2.03.12');

      debugPrint('[AppUpdateService] Force update required. Redirecting...');
      Get.offAll(
        () => AppUpdateView(
          url: downloadUri,
          title: "New Version Available",
          message: subtitleMessage,
          currentVersion: currentVer,
          latestVersion: latestName,
        ),
      );
      return false;
    }

    // 3. Optional Update Check
    if (info.data.clientVersionCheck?.hasUpdate == true) {
      final downloadUrlString = info.data.clientVersionCheck?.downloadUrl ??
          (Platform.isIOS
              ? info.data.downloads.appStoreUrl
              : info.data.downloads.googlePlayUrl);
      final downloadUri = Uri.tryParse(downloadUrlString) ??
          Uri.parse('https://play.google.com/store/apps/details?id=com.techyfo.lokkha');

      showOptionalUpdateDialog(downloadUri, info.data.clientVersionCheck?.message);
    }

    return true;
  }

  /// Non-blocking update dialog for optional updates
  void showOptionalUpdateDialog(Uri url, String? message) {
    Get.defaultDialog(
      title: "নতুন আপডেট উপলব্ধ",
      titlePadding: const EdgeInsets.only(top: 16.0),
      buttonColor: LightThemeColors.primaryColor,
      cancelTextColor: LightThemeColors.black,
      confirmTextColor: LightThemeColors.white,
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        children: [
          Image.asset(AssetImagePaths.appIcon, width: 80),
          const SizedBox(height: 12.0),
          Text(
            message?.isNotEmpty == true
                ? message!
                : "অ্যাপের নতুন সংস্করণ এসেছে। নতুন ফিচার উপভোগ করতে এখনই আপডেট করুন।",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      onConfirm: () async {
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $url');
        }
      },
      onCancel: () => Get.back(),
      textConfirm: "আপডেট করুন",
      textCancel: "পরে",
    );
  }

  /// Displays the dynamic In-App Announcement popup if enabled and not yet shown
  void showInAppAnnouncementIfAvailable() {
    if (hasShownInAppPopup) return;
    final popup = appInfo.value?.data.announcements.inAppPopup;
    if (popup != null && popup.enabled) {
      hasShownInAppPopup = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        InAppPopupDialog.show(popup);
      });
    }
  }

  /// Backward compatibility for legacy calls
  Future<void> appVersionCheck() async {
    await fetchAppInfoAndCheckVersion();
    handleStartupFlow();
  }
}
