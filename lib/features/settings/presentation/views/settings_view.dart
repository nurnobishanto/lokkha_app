import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/app_system/app_system.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/profile/presentation/widgets/change_password_sheet.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/shared/widgets/theme/theme_toggle_tile.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'সেটিংস',
        centerTitle: true,
      ),
      body: Obx(() {
        if (!isLoggedIn.value) {
          return const AuthGatewayView();
        }

        final user = controller.currentUser.value;

        return RefreshIndicator(
          onRefresh: controller.refreshSettings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. MINI USER PROFILE HEADER
                _buildUserProfileBanner(context, user),

                SizedBox(height: 18.h),

                // 2. MODULE: DEVICE & SESSION MANAGEMENT (API: /api/v1/user/devices)
                _buildDeviceManagementModule(context, controller),

                SizedBox(height: 20.h),

                // 3. MODULE: SECURITY & PASSWORD
                _buildSecurityModule(context),

                SizedBox(height: 20.h),

                // 4. MODULE: DISPLAY & PREFERENCES
                _buildPreferencesModule(context),

                SizedBox(height: 20.h),

                // 5. MODULE: SUPPORT & LEGAL
                _buildSupportAndLegalModule(context),

                SizedBox(height: 20.h),

                // 6. MODULE: ACCOUNT CONTROL (DANGER ZONE)
                _buildAccountControlModule(context),

                SizedBox(height: 14.h),

                // App Version Footer
                Center(
                  child: Text(
                    "লক্ষা অ্যাপ v1.0.0 • সকল স্বত্ব সংরক্ষিত",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. USER PROFILE BANNER CARD
  // ---------------------------------------------------------------------------
  Widget _buildUserProfileBanner(BuildContext context, dynamic user) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF064E3B),
            Color(0xFF095A43),
            Color(0xFF0F6E52),
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: buildAvatar(user, radius: 28.r),
          ),
          SizedBox(width: 14.w),

          // Name, ID & Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? "শিক্ষার্থী",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: user.userId ?? user.phone ?? ""),
                        );
                        CustomSnackBar.showCustomToast(message: "আইডি কপি করা হয়েছে!");
                      },
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "ID: ${user.userId ?? 'C05189'}",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        user.phone ?? "",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit profile button
          InkWell(
            onTap: () => Get.toNamed(Routes.PROFILE_UPDATE),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, size: 14.sp, color: const Color(0xFF064E3B)),
                  SizedBox(width: 4.w),
                  Text(
                    "এডিট",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF064E3B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. DEVICE & SESSION MANAGEMENT MODULE (API: /api/v1/user/devices)
  // ---------------------------------------------------------------------------
  Widget _buildDeviceManagementModule(
    BuildContext context,
    SettingsController controller,
  ) {
    final devicesData = controller.userDevices.value;
    final activeCount = devicesData?.activeCount ?? 0;
    final maxAllowed = devicesData?.maxAllowed ?? 3;
    final devices = devicesData?.activeDevices ?? [];

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
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
                    "ডিভাইস ও সেশন",
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              // Active count badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: activeCount >= maxAllowed
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: activeCount >= maxAllowed
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Text(
                  "$activeCount / $maxAllowed টি সক্রিয়",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: activeCount >= maxAllowed
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Policy Info Card (Max 3: 1 Android, 1 iOS, 1 Windows)
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: context.isDark
                  ? context.surfaceColor
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15.sp,
                      color: context.primaryColor,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        "সর্বোচ্চ ৩টি ডিভাইসে (১টি Android, ১টি iOS, ১টি Windows) একসাথে সেশন সক্রিয় রাখা যায়। অতিরিক্ত ডিভাইসে লগইন করতে পূর্ববর্তী সেশন বন্ধ করুন।",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: context.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Platform indicator row
                Row(
                  children: [
                    _buildPlatformChip(
                      label: "Android",
                      icon: Icons.android_rounded,
                      isOccupied: devices.any((d) =>
                          d.platformCategory?.toLowerCase() == 'android' ||
                          d.platform.toLowerCase().contains('android')),
                      context: context,
                    ),
                    SizedBox(width: 8.w),
                    _buildPlatformChip(
                      label: "iOS",
                      icon: Icons.apple_rounded,
                      isOccupied: devices.any((d) =>
                          d.platformCategory?.toLowerCase() == 'ios' ||
                          d.platform.toLowerCase().contains('ios')),
                      context: context,
                    ),
                    SizedBox(width: 8.w),
                    _buildPlatformChip(
                      label: "Windows",
                      icon: Icons.laptop_windows_rounded,
                      isOccupied: devices.any((d) =>
                          d.platformCategory?.toLowerCase() == 'windows' ||
                          d.platform.toLowerCase().contains('win')),
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Devices List
          if (controller.isLoadingDevices.value) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ] else if (devices.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  "কোনো সক্রিয় ডিভাইস সেশন পাওয়া যায়নি",
                  style: TextStyle(fontSize: 12.5.sp, color: context.textMuted),
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final device = devices[index];
                return _buildDeviceCard(context, controller, device);
              },
            ),
          ],

          // Logout all other devices action button (if more than 1 device)
          if (devices.length > 1) ...[
            SizedBox(height: 14.h),
            InkWell(
              onTap: controller.isLoggingOutOthers.value
                  ? null
                  : () => controller.logoutOtherDevices(context),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 14.w),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF4C0519).withValues(alpha: 0.3)
                      : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: context.isDark
                        ? const Color(0xFF881337)
                        : const Color(0xFFFECDD3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.isLoggingOutOthers.value)
                      SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE11D48),
                        ),
                      )
                    else
                      Icon(
                        Icons.phonelink_erase_rounded,
                        color: const Color(0xFFE11D48),
                        size: 18.sp,
                      ),
                    SizedBox(width: 8.w),
                    Text(
                      "অন্যান্য সব ডিভাইস থেকে লগ আউট করুন",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlatformChip({
    required String label,
    required IconData icon,
    required bool isOccupied,
    required BuildContext context,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isOccupied
              ? (context.isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                  : const Color(0xFFECFDF5))
              : (context.isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isOccupied
                ? (context.isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0))
                : context.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: isOccupied ? const Color(0xFF059669) : context.textMuted,
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: isOccupied ? FontWeight.bold : FontWeight.w500,
                  color: isOccupied ? const Color(0xFF059669) : context.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    SettingsController controller,
    DeviceSessionModel device,
  ) {
    final isTerminating = controller.terminatingDeviceId.value == device.id;

    IconData platformIcon = Icons.devices_other_rounded;
    Color iconColor = const Color(0xFF059669);
    Color iconBg = const Color(0xFFECFDF5);

    final pCat = device.platformCategory?.toLowerCase() ?? device.platform.toLowerCase();
    if (pCat.contains('android')) {
      platformIcon = Icons.android_rounded;
      iconColor = const Color(0xFF16A34A);
      iconBg = const Color(0xFFF0FDF4);
    } else if (pCat.contains('ios') || pCat.contains('apple') || pCat.contains('mac')) {
      platformIcon = Icons.apple_rounded;
      iconColor = context.isDark ? Colors.white : const Color(0xFF0F172A);
      iconBg = context.isDark ? Colors.grey.shade800 : const Color(0xFFF1F5F9);
    } else if (pCat.contains('win') || pCat.contains('desktop')) {
      platformIcon = Icons.desktop_windows_rounded;
      iconColor = const Color(0xFF2563EB);
      iconBg = const Color(0xFFEFF6FF);
    }

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.isDark ? context.surfaceColor : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: device.isCurrent
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : context.borderColor,
          width: device.isCurrent ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Platform Icon
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(platformIcon, color: iconColor, size: 22.sp),
            ),
          ),
          SizedBox(width: 12.w),

          // Details (Name, category, IP, last active)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.deviceName,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (device.isCurrent) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          "বর্তমান",
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  device.platformCategoryLabel ?? device.platform,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "IP: ${device.ipAddress ?? 'N/A'}${device.lastActiveAt != null ? ' • ${device.lastActiveAt}' : ''}",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: context.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Terminate Action Button
          if (!device.isCurrent) ...[
            SizedBox(width: 8.w),
            InkWell(
              onTap: isTerminating
                  ? null
                  : () => controller.terminateDevice(context, device),
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF4C0519).withValues(alpha: 0.3)
                      : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFFFECDD3),
                    width: 1,
                  ),
                ),
                child: isTerminating
                    ? SizedBox(
                        width: 14.r,
                        height: 14.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE11D48),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.power_settings_new_rounded,
                            size: 13.sp,
                            color: const Color(0xFFE11D48),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "বন্ধ করুন",
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. SECURITY & PASSWORD MODULE
  // ---------------------------------------------------------------------------
  Widget _buildSecurityModule(BuildContext context) {
    return _buildModuleContainer(
      context: context,
      title: "নিরাপত্তা ও পাসওয়ার্ড",
      icon: Icons.shield_outlined,
      children: [
        _buildListTile(
          context: context,
          icon: Icons.lock_reset_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFFEFF6FF),
          title: "পাসওয়ার্ড পরিবর্তন করুন",
          subtitle: "অ্যাকাউন্টের সুরক্ষায় নিয়মিত পাসওয়ার্ড আপডেট করুন",
          onTap: () => ChangePasswordSheet.show(context),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. DISPLAY & PREFERENCES MODULE
  // ---------------------------------------------------------------------------
  Widget _buildPreferencesModule(BuildContext context) {
    return _buildModuleContainer(
      context: context,
      title: "ইন্টারফেস ও সেটিংস",
      icon: Icons.tune_rounded,
      children: [
        const ThemeToggleTile(),
        const Divider(height: 0, indent: 56),
        _buildListTile(
          context: context,
          icon: Icons.notifications_active_outlined,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFFFBEB),
          title: "নোটিফিকেশন",
          subtitle: "পরীক্ষা ও লাইভ ইভেন্টের নোটিফিকেশন দেখুন",
          onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. SUPPORT & LEGAL MODULE
  // ---------------------------------------------------------------------------
  Widget _buildSupportAndLegalModule(BuildContext context) {
    return _buildModuleContainer(
      context: context,
      title: "সহায়তা ও নীতিমালা",
      icon: Icons.help_outline_rounded,
      children: [
        _buildListTile(
          context: context,
          icon: Icons.support_agent_rounded,
          iconColor: const Color(0xFF059669),
          iconBg: const Color(0xFFECFDF5),
          title: "সাহায্য ও কাস্টমার সাপোর্ট",
          subtitle: "যেকোনো সমস্যা বা সহায়তায় সরাসরি যোগাযোগ",
          onTap: () => Get.to(const CustomerSupportView()),
        ),
        const Divider(height: 0, indent: 56),
        _buildListTile(
          context: context,
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF4F46E5),
          iconBg: const Color(0xFFEEF2FF),
          title: "শর্তাবলী ও নীতিমালা",
          subtitle: "ব্যবহারের নিয়মাবলী এবং পলিসি পড়ুন",
          onTap: () => Get.toNamed(Routes.TERMS_CONDITION),
        ),
        const Divider(height: 0, indent: 56),
        _buildListTile(
          context: context,
          icon: Icons.privacy_tip_outlined,
          iconColor: const Color(0xFF0891B2),
          iconBg: const Color(0xFFECFEFF),
          title: "গোপনীয়তা নীতি (Privacy Policy)",
          subtitle: "আপনার ব্যক্তিগত তথ্যের গোপনীয়তা সম্পর্কিত তথ্যাবলী",
          onTap: () => openAppOrWebView("https://lokkha.com/page/privacy-policy"),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. ACCOUNT CONTROL (DANGER ZONE) MODULE
  // ---------------------------------------------------------------------------
  Widget _buildAccountControlModule(BuildContext context) {
    return _buildModuleContainer(
      context: context,
      title: "অ্যাকাউন্ট অ্যাকশন",
      icon: Icons.account_circle_outlined,
      children: [
        _buildListTile(
          context: context,
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          iconBg: const Color(0xFFFEF2F2),
          title: "অ্যাকাউন্ট ডিলিট রিকোয়েস্ট",
          subtitle: "অ্যাকাউন্ট সম্পূর্ণভাবে মুছে ফেলার অনুরোধ জানান",
          titleColor: Colors.red.shade700,
          onTap: () {
            Get.defaultDialog(
              title: "অ্যাকাউন্ট ডিলিট",
              middleText: "অ্যাকাউন্ট স্থায়ীভাবে মুছে ফেলতে আমাদের কাস্টমার সার্ভিসের সাথে যোগাযোগ করুন।",
              textConfirm: "যোগাযোগ করুন",
              textCancel: "বাতিল",
              confirmTextColor: Colors.white,
              buttonColor: Colors.red,
              onConfirm: () {
                Get.back();
                Get.to(const CustomerSupportView());
              },
            );
          },
        ),
        const Divider(height: 0, indent: 56),
        _buildListTile(
          context: context,
          icon: Icons.logout_rounded,
          iconColor: Colors.redAccent,
          iconBg: const Color(0xFFFFF1F2),
          title: "লগ আউট",
          subtitle: "বর্তমান সেশন থেকে বের হয়ে যান",
          titleColor: Colors.redAccent,
          onTap: () => AuthService.confirmAndLogout(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildModuleContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
              child: Row(
                children: [
                  Icon(icon, size: 18.sp, color: context.primaryColor),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: context.isDark ? iconBg.withValues(alpha: 0.15) : iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 19.sp),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.textMuted,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textMuted,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
