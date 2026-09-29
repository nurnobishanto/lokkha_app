import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class DevicesManagementSheet extends StatefulWidget {
  const DevicesManagementSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DevicesManagementSheet(),
    );
  }

  @override
  State<DevicesManagementSheet> createState() => _DevicesManagementSheetState();
}

class _DevicesManagementSheetState extends State<DevicesManagementSheet> {
  final ProfileRepository _repository = ProfileRepository();
  bool _isLoading = true;
  UserDevicesData? _devicesData;
  List<DeviceSessionModel> _devices = [];

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getDevices();
      if (mounted) {
        setState(() {
          _devicesData = data;
          _devices = data?.activeDevices ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _terminateDevice(DeviceSessionModel device) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          "ডিভাইস সেশন বন্ধ",
          style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "আপনি কি নিশ্চিত যে '${device.deviceName}' ডিভাইসের সেশনটি বন্ধ করতে চান?",
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("বাতিল", style: TextStyle(color: context.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Get.back(result: true),
            child: const Text("বন্ধ করুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await _repository.terminateDevice(device.id);
      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        final isCurrent = res['data'] is Map && res['data']['is_current_device'] == true;
        if (isCurrent || device.isCurrent) {
          if (mounted) Navigator.pop(context);
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
        _fetchDevices();
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "ব্যর্থ",
          message: res['message']?.toString() ?? "ডিভাইস সেশন বন্ধ করা সম্ভব হয়নি।",
        );
      }
    }
  }

  Future<void> _terminateOtherDevices() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          "অন্যান্য ডিভাইস লগআউট",
          style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "আপনি কি বর্তমান মোবাইল ডিভাইস ছাড়া অন্য সকল সক্রিয় ডিভাইস থেকে লগআউট করতে চান?",
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("না", style: TextStyle(color: context.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Get.back(result: true),
            child: const Text("লগআউট", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await _repository.logoutOtherDevices();
      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        CustomSnackBar.showCustomToast(
          message: res['message']?.toString() ?? "অন্য সকল ডিভাইস থেকে সফলভাবে লগআউট করা হয়েছে।",
        );
        _fetchDevices();
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "ব্যর্থ",
          message: res['message']?.toString() ?? "অন্যান্য ডিভাইস লগআউট করা যায়নি।",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _devicesData?.activeCount ?? _devices.length;
    final maxAllowed = _devicesData?.maxAllowed ?? 3;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.devices_rounded,
                      color: context.primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "সক্রিয় ডিভাইসসমূহ",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: context.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "$activeCount / $maxAllowed টি সক্রিয়",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "সর্বোচ্চ ৩টি ডিভাইসে (১টি অ্যান্ড্রয়েড, ১টি আইওএস, ১টি উইন্ডোজ) একই সাথে সক্রিয় সেশন রাখা যাবে।",
            style: TextStyle(fontSize: 11.5.sp, color: context.textMuted),
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _devices.isEmpty
                    ? Center(
                        child: Text(
                          "কোন ডিভাইস সেশন পাওয়া যায়নি",
                          style: TextStyle(fontSize: 13.sp, color: context.textMuted),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          final platformIcon = _getDeviceIcon(device.platform, device.deviceType);

                          return Card(
                            margin: EdgeInsets.only(bottom: 10.h),
                            elevation: 0,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              side: BorderSide(
                                color: device.isCurrent
                                    ? context.primaryColor
                                    : context.borderColor,
                                width: device.isCurrent ? 1.5 : 1,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: device.isCurrent
                                          ? context.primaryColor.withValues(alpha: 0.12)
                                          : Colors.grey.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      platformIcon,
                                      color: device.isCurrent
                                          ? context.primaryColor
                                          : context.textMuted,
                                      size: 22.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                device.deviceName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5.sp,
                                                  color: context.textPrimary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (device.isCurrent)
                                              Container(
                                                margin: EdgeInsets.only(left: 6.w),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w, vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(10.r),
                                                ),
                                                child: Text(
                                                  "বর্তমান ডিভাইস",
                                                  style: TextStyle(
                                                    color: Colors.green.shade700,
                                                    fontSize: 9.5.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          device.platformCategoryLabel ??
                                              "${device.platform.toUpperCase()} (${device.deviceType})",
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            color: context.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          "${device.ipAddress != null ? 'IP: ${device.ipAddress} • ' : ''}${device.lastActiveAt != null ? 'সর্বশেষ সক্রিয়: ${device.lastActiveAt}' : (device.loginAt != null ? 'লগইন: ${device.loginAt}' : 'সক্রিয় সেশন')}",
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            color: context.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!device.isCurrent)
                                    IconButton(
                                      tooltip: "ডিভাইস সেশন বন্ধ করুন",
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => _terminateDevice(device),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (_devices.length > 1)
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: _terminateOtherDevices,
                  icon: const Icon(Icons.phonelink_erase, size: 18),
                  label: const Text(
                    "অন্যান্য সকল ডিভাইস লগআউট করুন",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String platform, String deviceType) {
    final p = platform.toLowerCase();
    final d = deviceType.toLowerCase();
    if (p.contains('ios') || p.contains('apple')) {
      return Icons.phone_iphone;
    } else if (p.contains('android')) {
      return Icons.phone_android;
    } else if (p.contains('windows') || d.contains('desktop')) {
      return Icons.desktop_windows;
    } else if (p.contains('mac')) {
      return Icons.laptop_mac;
    }
    return Icons.devices;
  }
}
