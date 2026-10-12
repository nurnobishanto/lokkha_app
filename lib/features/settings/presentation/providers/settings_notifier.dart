import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class SettingsState {
  final UserDevicesData? userDevices;
  final bool isLoadingDevices;
  final int? terminatingDeviceId;
  final bool isLoggingOutOthers;
  final User currentUser;

  const SettingsState({
    this.userDevices,
    this.isLoadingDevices = true,
    this.terminatingDeviceId,
    this.isLoggingOutOthers = false,
    required this.currentUser,
  });

  SettingsState copyWith({
    UserDevicesData? userDevices,
    bool? isLoadingDevices,
    int? terminatingDeviceId,
    bool clearTerminatingDeviceId = false,
    bool? isLoggingOutOthers,
    User? currentUser,
  }) {
    return SettingsState(
      userDevices: userDevices ?? this.userDevices,
      isLoadingDevices: isLoadingDevices ?? this.isLoadingDevices,
      terminatingDeviceId: clearTerminatingDeviceId
          ? null
          : (terminatingDeviceId ?? this.terminatingDeviceId),
      isLoggingOutOthers: isLoggingOutOthers ?? this.isLoggingOutOthers,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late final GetDevicesUseCase _getDevicesUseCase;
  late final TerminateDeviceUseCase _terminateDeviceUseCase;
  late final LogoutOtherDevicesUseCase _logoutOtherDevicesUseCase;
  late final GetProfileUseCase _getProfileUseCase;

  @override
  SettingsState build() {
    _getDevicesUseCase = GetDevicesUseCase(repository: ProfileRepository());
    _terminateDeviceUseCase =
        TerminateDeviceUseCase(repository: ProfileRepository());
    _logoutOtherDevicesUseCase =
        LogoutOtherDevicesUseCase(repository: ProfileRepository());
    _getProfileUseCase = GetProfileUseCase(repository: ProfileRepository());

    Future.microtask(() {
      fetchDevices();
      fetchProfile();
    });

    return SettingsState(currentUser: myUser);
  }

  Future<void> refreshSettings() async {
    await Future.wait([
      fetchDevices(),
      fetchProfile(),
    ]);
  }

  Future<void> fetchDevices() async {
    state = state.copyWith(isLoadingDevices: true);
    try {
      final data = await _getDevicesUseCase();
      state = state.copyWith(userDevices: data, isLoadingDevices: false);
    } catch (e) {
      debugPrint('[SettingsNotifier] fetchDevices error: $e');
      state = state.copyWith(isLoadingDevices: false);
    }
  }

  Future<void> fetchProfile() async {
    try {
      final profile = await _getProfileUseCase();
      if (profile != null) {
        myUser = profile;
        state = state.copyWith(currentUser: profile);
      }
    } catch (e) {
      debugPrint('[SettingsNotifier] fetchProfile error: $e');
    }
  }

  Future<void> terminateDevice(
      BuildContext context, DeviceSessionModel device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          device.isCurrent ? "বর্তমান সেশন লগ আউট" : "ডিভাইস সেশন বন্ধ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          device.isCurrent
              ? "আপনি কি বর্তমান সেশন থেকে লগ আউট করতে চান?"
              : "আপনি কি নিশ্চিত যে '${device.deviceName}' ডিভাইসের সেশনটি বন্ধ করতে চান?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("বাতিল"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("বন্ধ করুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    state = state.copyWith(terminatingDeviceId: device.id);
    try {
      final res = await _terminateDeviceUseCase(device.id);
      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        final isCurrent =
            res['data'] is Map && res['data']['is_current_device'] == true;
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
          message: res['message']?.toString() ??
              "ডিভাইস সেশন সফলভাবে বন্ধ করা হয়েছে।",
        );
        await fetchDevices();
      } else {
        CustomSnackBar.showCustomToast(
          message:
              res['message']?.toString() ?? "ডিভাইস সেশন বন্ধ করা সম্ভব হয়নি",
        );
      }
    } catch (e) {
      CustomSnackBar.showCustomToast(
        message: "ডিভাইস সেশন বন্ধ করার সময় ত্রুটি হয়েছে: $e",
      );
    } finally {
      state = state.copyWith(clearTerminatingDeviceId: true);
    }
  }

  Future<void> logoutOtherDevices(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "অন্যান্য ডিভাইস লগ আউট",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "বর্তমান ডিভাইস বাদে অন্য সকল সক্রিয় ডিভাইস থেকে লগ আউট করতে চান?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("বাতিল"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("সবগুলো লগ আউট",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    state = state.copyWith(isLoggingOutOthers: true);
    try {
      final res = await _logoutOtherDevicesUseCase();
      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        final count =
            (res['data'] is Map && res['data']['terminated_count'] != null)
                ? res['data']['terminated_count']
                : null;
        final msg = count != null
            ? "$count টি অন্যান্য ডিভাইস সেশন বন্ধ করা হয়েছে।"
            : (res['message']?.toString() ??
                "অন্যান্য সকল ডিভাইস থেকে লগ আউট সম্পন্ন হয়েছে।");
        CustomSnackBar.showCustomToast(message: msg);
        await fetchDevices();
      } else {
        CustomSnackBar.showCustomToast(
          message: res['message']?.toString() ??
              "অন্যান্য ডিভাইস লগ আউট করা সম্ভব হয়নি",
        );
      }
    } catch (e) {
      CustomSnackBar.showCustomToast(
        message: "অন্যান্য ডিভাইস লগ আউট করার সময় ত্রুটি হয়েছে: $e",
      );
    } finally {
      state = state.copyWith(isLoggingOutOthers: false);
    }
  }
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
