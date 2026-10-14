import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/app/theme/app_theme.dart';
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
  final ValueNotifier<AppInfoModel?> appInfo = ValueNotifier<AppInfoModel?>(null);
  final ValueNotifier<bool> isChecking = ValueNotifier<bool>(false);
  final ValueNotifier<bool> updateRequiredCheck = ValueNotifier<bool>(false);
  final ValueNotifier<bool> firstAppUpdateCalled = ValueNotifier<bool>(false);

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

    final context = rootNavigatorKey.currentContext;

    // 1. Maintenance Mode Check
    if (maintenanceMode) {
      debugPrint('[AppUpdateService] System under maintenance. Redirecting...');
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MaintenanceModeView(
              title: info.data.systemStatus.maintenanceTitle,
              message: info.data.systemStatus.maintenanceMessage,
            ),
          ),
          (_) => false,
        );
      }
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
      const subtitleMessage = "নতুন ফিচার, উন্নত সেবা ও আরও ভালো অভিজ্ঞতার জন্য অনুগ্রহ করে অ্যাপটি আপডেট করে নিন।";

      final currentVer = appVersion.value.isNotEmpty
          ? appVersion.value
          : (info.data.clientVersionCheck?.currentVersion.isNotEmpty == true
              ? info.data.clientVersionCheck!.currentVersion
              : '2.03.12');

      debugPrint('[AppUpdateService] Force update required. Redirecting...');
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AppUpdateView(
              url: downloadUri,
              title: "New Version Available",
              message: subtitleMessage,
              currentVersion: currentVer,
              latestVersion: latestName,
            ),
          ),
          (_) => false,
        );
      }
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
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.only(top: 16.0),
        contentPadding: const EdgeInsets.all(16),
        title: const Text("নতুন আপডেট উপলব্ধ", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("পরে", style: TextStyle(color: LightThemeColors.black)),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: LightThemeColors.primaryColor),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                debugPrint('Could not launch $url');
              }
            },
            child: const Text("আপডেট করুন", style: TextStyle(color: LightThemeColors.white)),
          ),
        ],
      ),
    );
  }

  /// Displays the dynamic In-App Announcement popup if enabled, not yet shown,
  /// and the user is on the Home screen.
  void showInAppAnnouncementIfAvailable({BuildContext? context, bool force = false}) {
    if (hasShownInAppPopup && !force) return;

    if (appInfo.value == null) {
      fetchAppInfoAndCheckVersion().then((_) {
        _displayPopupIfEligible(force: force);
      });
      return;
    }

    _displayPopupIfEligible(context: context, force: force);
  }

  void _displayPopupIfEligible({BuildContext? context, bool force = false}) {
    if (hasShownInAppPopup && !force) return;
    final popup = appInfo.value?.data.announcements.inAppPopup;
    if (popup == null || !popup.enabled) return;
    if (InAppPopupDialog.isShowing) return;

    final targetContext = context ?? rootNavigatorKey.currentContext;
    if (targetContext == null) return;

    // Immediately mark as shown to prevent duplicate triggers across the app session
    hasShownInAppPopup = true;
    debugPrint(
        '[AppUpdateService] showInAppAnnouncementIfAvailable: popup=${popup.heading}, enabled=${popup.enabled}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (targetContext.mounted && !InAppPopupDialog.isShowing) {
        debugPrint(
            '[AppUpdateService] Displaying InAppPopupDialog on Home screen: ${popup.heading}');
        InAppPopupDialog.show(popup, context: targetContext);
      }
    });
  }

  /// Backward compatibility for legacy calls
  Future<void> appVersionCheck() async {
    await fetchAppInfoAndCheckVersion();
    handleStartupFlow();
  }
}
