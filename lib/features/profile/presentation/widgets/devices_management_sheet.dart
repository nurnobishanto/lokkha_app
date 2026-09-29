import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/theme/text_style.dart';
import 'package:lokkha/features/profile/profile.dart';

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
  final DeviceSessionRepository _repository = DeviceSessionRepository();
  bool _isLoading = true;
  List<DeviceSessionModel> _devices = [];

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    setState(() => _isLoading = true);
    final list = await _repository.getActiveDevices();
    setState(() {
      _devices = list;
      _isLoading = false;
    });
  }

  Future<void> _terminateOtherDevices() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("অন্যান্য ডিভাইস লগআউট"),
        content: const Text("আপনি কি বর্তমান ডিভাইস ছাড়া অন্য সকল ডিভাইস থেকে লগআউট করতে চান?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text("না")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Get.back(result: true),
            child: const Text("লগআউট", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _repository.logoutOtherDevices();
      if (success) {
        Get.snackbar("সফল", "অন্য সকল ডিভাইস থেকে সফলভাবে লগআউট করা হয়েছে।",
            backgroundColor: Colors.black87, colorText: Colors.white);
        _fetchDevices();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "সক্রিয় ডিভাইস সমূহ (সর্বোচ্চ ৩টি)",
                style: AppTextStyles.heading4.copyWith(color: LightThemeColors.black),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(
            "আপনার অ্যাকাউন্টের নিরাপত্তা নিশ্চিত করতে সর্বোচ্চ ৩টি ডিভাইসে একসাথে লগইন করা যায়।",
            style: AppTextStyles.body2.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _devices.isEmpty
                    ? Center(
                        child: Text(
                          "কোন ডিভাইস তথ্য পাওয়া যায়নি",
                          style: AppTextStyles.body2.copyWith(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 10.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(
                                color: device.isCurrent
                                    ? LightThemeColors.primaryColor
                                    : Colors.grey.shade200,
                                width: device.isCurrent ? 1.5 : 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                device.platform.toLowerCase().contains('ios')
                                    ? Icons.phone_iphone
                                    : Icons.phone_android,
                                color: device.isCurrent
                                    ? LightThemeColors.primaryColor
                                    : Colors.grey,
                                size: 28.sp,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      device.deviceName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                  if (device.isCurrent)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        "বর্তমান ডিভাইস",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                device.lastActiveAt != null
                                    ? "সর্বশেষ সক্রিয়: ${device.lastActiveAt}"
                                    : "সক্রিয় সেশন",
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                              ),
                              trailing: device.isCurrent
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () async {
                                        final ok = await _repository.logoutDevice(device.id);
                                        if (ok) {
                                          _fetchDevices();
                                        }
                                      },
                                    ),
                            ),
                          );
                        },
                      ),
          ),
          if (_devices.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: _terminateOtherDevices,
                  icon: const Icon(Icons.phonelink_erase),
                  label: const Text("অন্যান্য সকল ডিভাইস লগআউট করুন"),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
