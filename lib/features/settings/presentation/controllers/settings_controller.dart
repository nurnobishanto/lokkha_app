import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class SettingsController extends GetxController {
  final GetDevicesUseCase _getDevicesUseCase;
  final TerminateDeviceUseCase _terminateDeviceUseCase;
  final LogoutOtherDevicesUseCase _logoutOtherDevicesUseCase;
  final GetProfileUseCase _getProfileUseCase;

  SettingsController({
    GetDevicesUseCase? getDevicesUseCase,
    TerminateDeviceUseCase? terminateDeviceUseCase,
    LogoutOtherDevicesUseCase? logoutOtherDevicesUseCase,
    GetProfileUseCase? getProfileUseCase,
  })  : _getDevicesUseCase =
            getDevicesUseCase ?? GetDevicesUseCase(repository: ProfileRepository()),
        _terminateDeviceUseCase =
            terminateDeviceUseCase ?? TerminateDeviceUseCase(repository: ProfileRepository()),
        _logoutOtherDevicesUseCase =
            logoutOtherDevicesUseCase ?? LogoutOtherDevicesUseCase(repository: ProfileRepository()),
        _getProfileUseCase =
            getProfileUseCase ?? GetProfileUseCase(repository: ProfileRepository());

  // Observables
  final Rx<UserDevicesData?> userDevices = Rx<UserDevicesData?>(null);
  final RxBool isLoadingDevices = true.obs;
  final RxnInt terminatingDeviceId = RxnInt();
  final RxBool isLoggingOutOthers = false.obs;
  final Rx<User> currentUser = myUser.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
    fetchProfile();
  }

  /// Refreshes all settings data (devices & user profile)
  Future<void> refreshSettings() async {
    await Future.wait([
      fetchDevices(),
      fetchProfile(),
    ]);
  }

  /// Fetches active device sessions and limits
  Future<void> fetchDevices() async {
    isLoadingDevices.value = true;
    try {
      final data = await _getDevicesUseCase();
      userDevices.value = data;
    } catch (e) {
      debugPrint('[SettingsController] fetchDevices error: $e');
    } finally {
      isLoadingDevices.value = false;
    }
  }

  /// Fetches the latest user profile
  Future<void> fetchProfile() async {
    try {
      final profile = await _getProfileUseCase();
      if (profile != null) {
        currentUser.value = profile;
        myUser = profile;
      }
    } catch (e) {
      debugPrint('[SettingsController] fetchProfile error: $e');
    }
  }

  /// Terminates a specific device session
  Future<void> terminateDevice(BuildContext context, DeviceSessionModel device) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          device.isCurrent ? "বর্তমান সেশন লগ আউট" : "ডিভাইস সেশন বন্ধ",
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          device.isCurrent
              ? "আপনি কি বর্তমান সেশন থেকে লগ আউট করতে চান?"
              : "আপনি কি নিশ্চিত যে '${device.deviceName}' ডিভাইসের সেশনটি বন্ধ করতে চান?",
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("বাতিল", style: TextStyle(color: context.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text("বন্ধ করুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    terminatingDeviceId.value = device.id;
    try {
      final res = await _terminateDeviceUseCase(device.id);
      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        final isCurrent = res['data'] is Map && res['data']['is_current_device'] == true;
        if (isCurrent || device.isCurrent) {
          CustomSnackBar.showCustomToast(
            message: "বর্তমান ডিভাইস সেশন বন্ধ করা হয়েছে।",
          );
          AuthService().handleSessionExpired(
            message: "আপনার বর্তমান ডিভাইস সেশনটি সমাপ্ত করা হয়েছে।",
          );
          return;
        }

        CustomSnackBar.showCustomToast(
          message: res['message']?.toString() ?? "ডিভাইস সেশন সফলভাবে বন্ধ করা হয়েছে।",
        );
        await fetchDevices();
      } else {
        CustomSnackBar.showCustomToast(
          message: res['message']?.toString() ?? "ডিভাইস সেশন বন্ধ করা সম্ভব হয়নি",
        );
      }
    } catch (e) {
      CustomSnackBar.showCustomToast(
        message: "ডিভাইস সেশন বন্ধ করার সময় ত্রুটি হয়েছে: $e",
      );
    } finally {
      terminatingDeviceId.value = null;
    }
  }

  /// Logs out all other devices except the current mobile device
  Future<void> logoutOtherDevices(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "অন্যান্য ডিভাইস লগ আউট",
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "বর্তমান ডিভাইস বাদে অন্য সকল সক্রিয় ডিভাইস থেকে লগ আউট করতে চান?",
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("বাতিল", style: TextStyle(color: context.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text("সবগুলো লগ আউট", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoggingOutOthers.value = true;
    try {
      final res = await _logoutOtherDevicesUseCase();
      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        final count = (res['data'] is Map && res['data']['terminated_count'] != null)
            ? res['data']['terminated_count']
            : null;
        final msg = count != null
            ? "$count টি অন্যান্য ডিভাইস সেশন বন্ধ করা হয়েছে।"
            : (res['message']?.toString() ?? "অন্যান্য সকল ডিভাইস থেকে লগ আউট সম্পন্ন হয়েছে।");
        CustomSnackBar.showCustomToast(message: msg);
        await fetchDevices();
      } else {
        CustomSnackBar.showCustomToast(
          message: res['message']?.toString() ?? "অন্যান্য ডিভাইস লগ আউট করা সম্ভব হয়নি",
        );
      }
    } catch (e) {
      CustomSnackBar.showCustomToast(
        message: "অন্যান্য ডিভাইস লগ আউট করার সময় ত্রুটি হয়েছে: $e",
      );
    } finally {
      isLoggingOutOthers.value = false;
    }
  }
}
