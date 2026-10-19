import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/app_system/app_system.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/profile/data/models/device_session_model.dart';
import 'package:lokkha/features/profile/presentation/widgets/change_password_sheet.dart';
import 'package:lokkha/shared/widgets/theme/theme_toggle_tile.dart';
import '../providers/settings_notifier.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isLoggedIn.value) {
      return const Scaffold(body: AuthGatewayView());
    }

    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'সেটিংস',
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF006A4E),
        onRefresh: notifier.refreshSettings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. DEVICE & SESSION MANAGEMENT MODULE
              _buildDeviceManagementModule(context, state, notifier),

              SizedBox(height: 12.h),

              // 2. SECURITY & PASSWORD MODULE
              _buildSecurityModule(context),

              SizedBox(height: 12.h),

              // 3. DISPLAY & PREFERENCES MODULE (Dark Mode)
              _buildPreferencesModule(context),

              SizedBox(height: 12.h),

              // 4. ACCOUNT CONTROL (DANGER ZONE)
              _buildAccountControlModule(context),

              SizedBox(height: 18.h),

              // App Version & Copyright Footer
              Center(
                child: Text(
                  "লক্ষা অ্যাপ v1.0.0 • সকল স্বত্ব সংরক্ষিত",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.textMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. DEVICE & SESSION MANAGEMENT MODULE (COMPACT & CLEAN)
  // ---------------------------------------------------------------------------
  Widget _buildDeviceManagementModule(
    BuildContext context,
    SettingsState state,
    SettingsNotifier notifier,
  ) {
    final devicesData = state.userDevices;
    final activeCount = devicesData?.activeCount ?? 0;
    final maxAllowed = devicesData?.maxAllowed ?? 3;
    final devices = devicesData?.activeDevices ?? [];
    final bool isLimitReached = activeCount >= maxAllowed;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title + Pill
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.devices_rounded,
                  color: const Color(0xFF006A4E),
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "ডিভাইস ও সেশন",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              // Active count badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isLimitReached
                      ? (context.isDark
                          ? const Color(0xFF451A03)
                          : const Color(0xFFFFFBEB))
                      : (context.isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                          : const Color(0xFFECFDF5)),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isLimitReached
                        ? const Color(0xFFFCD34D)
                        : const Color(0xFFA7F3D0),
                    width: 1,
                  ),
                ),
                child: Text(
                  "$activeCount / $maxAllowed টি সক্রিয়",
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isLimitReached
                        ? const Color(0xFFD97706)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Policy Info Card (Compact)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: context.isDark
                  ? context.surfaceColor
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
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
                      size: 14.sp,
                      color: const Color(0xFF006A4E),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        "সর্বোচ্চ ৩টি ডিভাইসে (১টি Android, ১টি iOS, ১টি Windows) একসাথে সেশন সক্রিয় রাখা যায়।",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

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
                    SizedBox(width: 6.w),
                    _buildPlatformChip(
                      label: "iOS",
                      icon: Icons.apple_rounded,
                      isOccupied: devices.any((d) =>
                          d.platformCategory?.toLowerCase() == 'ios' ||
                          d.platform.toLowerCase().contains('ios') ||
                          d.platform.toLowerCase().contains('mac')),
                      context: context,
                    ),
                    SizedBox(width: 6.w),
                    _buildPlatformChip(
                      label: "Windows",
                      icon: Icons.laptop_windows_rounded,
                      isOccupied: devices.any((d) =>
                          d.platformCategory?.toLowerCase() == 'windows' ||
                          d.platform.toLowerCase().contains('win') ||
                          d.platform.toLowerCase().contains('pc')),
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // Devices List
          if (state.isLoadingDevices) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF006A4E)),
              ),
            ),
          ] else if (devices.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Center(
                child: Text(
                  "কোনো সক্রিয় ডিভাইস সেশন পাওয়া যায়নি",
                  style: TextStyle(fontSize: 12.sp, color: context.textMuted),
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (_, __) => SizedBox(height: 6.h),
              itemBuilder: (context, index) {
                final device = devices[index];
                return _buildDeviceCard(context, state, notifier, device);
              },
            ),
          ],

          // Logout all other devices action button
          if (devices.length > 1) ...[
            SizedBox(height: 10.h),
            InkWell(
              onTap: state.isLoggingOutOthers
                  ? null
                  : () => notifier.logoutOtherDevices(context),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF4C0519).withValues(alpha: 0.25)
                      : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: context.isDark
                        ? const Color(0xFF881337)
                        : const Color(0xFFFECDD3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isLoggingOutOthers)
                      SizedBox(
                        width: 14.r,
                        height: 14.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE11D48),
                        ),
                      )
                    else
                      Icon(
                        Icons.phonelink_erase_rounded,
                        color: const Color(0xFFE11D48),
                        size: 15.sp,
                      ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        "অন্যান্য সব ডিভাইস থেকে লগ আউট করুন",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE11D48),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isOccupied
              ? const Color(0xFF006A4E).withValues(alpha: context.isDark ? 0.2 : 0.08)
              : (context.isDark ? context.cardColor : Colors.white),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isOccupied
                ? const Color(0xFF006A4E).withValues(alpha: 0.3)
                : context.borderColor,
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13.sp,
                color: isOccupied ? const Color(0xFF006A4E) : context.textMuted,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: isOccupied ? FontWeight.bold : FontWeight.w500,
                  color: isOccupied ? const Color(0xFF006A4E) : context.textMuted,
                ),
                maxLines: 1,
              ),
              if (isOccupied) ...[
                SizedBox(width: 4.w),
                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    SettingsState state,
    SettingsNotifier notifier,
    DeviceSessionModel device,
  ) {
    final isTerminating = state.terminatingDeviceId == device.id;

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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.isDark ? context.surfaceColor : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: device.isCurrent
              ? const Color(0xFF006A4E).withValues(alpha: 0.35)
              : context.borderColor,
          width: device.isCurrent ? 1.2 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Platform Icon
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Icon(platformIcon, color: iconColor, size: 18.sp),
            ),
          ),
          SizedBox(width: 10.w),

          // Details (Name, category, IP/last active in clean compact format)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.deviceName,
                        style: TextStyle(
                          fontSize: 13.sp,
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
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          "বর্তমান",
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  "${device.platformCategoryLabel ?? device.platform}${device.lastActiveAt != null ? ' • ${device.lastActiveAt}' : (device.ipAddress != null ? ' • ${device.ipAddress}' : '')}",
                  style: TextStyle(
                    fontSize: 10.5.sp,
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
                  : () => notifier.terminateDevice(context, device),
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF4C0519).withValues(alpha: 0.3)
                      : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: const Color(0xFFFECDD3),
                    width: 1,
                  ),
                ),
                child: isTerminating
                    ? SizedBox(
                        width: 12.r,
                        height: 12.r,
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
                            size: 12.sp,
                            color: const Color(0xFFE11D48),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            "বন্ধ করুন",
                            style: TextStyle(
                              fontSize: 10.sp,
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
  // 2. SECURITY & PASSWORD MODULE (COMPACT & SUBTITLE-FREE)
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
          onTap: () => ChangePasswordSheet.show(context),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. DISPLAY & PREFERENCES MODULE (COMPACT & SUBTITLE-FREE)
  // ---------------------------------------------------------------------------
  Widget _buildPreferencesModule(BuildContext context) {
    return _buildModuleContainer(
      context: context,
      title: "ইন্টারফেস ও সেটিংস",
      icon: Icons.tune_rounded,
      children: const [
        ThemeToggleTile(
          showSubtitle: false,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. ACCOUNT CONTROL MODULE (COMPACT & SUBTITLE-FREE)
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
          titleColor: Colors.red.shade700,
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("অ্যাকাউন্ট ডিলিট"),
                content: const Text(
                  "অ্যাকাউন্ট স্থায়ীভাবে মুছে ফেলতে আমাদের কাস্টমার সার্ভিসের সাথে যোগাযোগ করুন।",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("বাতিল"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CustomerSupportView(),
                        ),
                      );
                    },
                    child: const Text("যোগাযোগ করুন"),
                  ),
                ],
              ),
            );
          },
        ),
        Divider(
          height: 1,
          indent: 52.w,
          color: context.borderColor,
        ),
        _buildListTile(
          context: context,
          icon: Icons.logout_rounded,
          iconColor: Colors.redAccent,
          iconBg: const Color(0xFFFFF1F2),
          title: "লগ আউট",
          titleColor: Colors.redAccent,
          onTap: () => AuthService.confirmAndLogout(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS (COMPACT, MINIMAL & PROFESSIONAL)
  // ---------------------------------------------------------------------------
  Widget _buildModuleContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(icon, size: 15.sp, color: const Color(0xFF006A4E)),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
            SizedBox(height: 4.h),
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
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: context.isDark ? iconBg.withValues(alpha: 0.15) : iconBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 17.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? context.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textMuted,
              size: 19.sp,
            ),
          ],
        ),
      ),
    );
  }
}
