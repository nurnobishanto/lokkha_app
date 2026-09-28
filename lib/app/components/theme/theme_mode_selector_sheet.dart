import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/theme_controller.dart';

/// Reusable Bottom Sheet for 3-state Theme Mode Selection:
/// - Light Mode
/// - Dark Mode
/// - System Default
class ThemeModeSelectorSheet extends StatelessWidget {
  const ThemeModeSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeModeSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.to;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'থিম সেটিংস',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      'অ্যাপের ডিসপ্লে মোড নির্বাচন করুন',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 18.h),

            // Options
            Obx(() {
              final current = controller.themeMode.value;
              return Column(
                children: [
                  _buildThemeOption(
                    context: context,
                    title: 'লাইট মোড',
                    subtitle: 'সবসময় উজ্জ্বল ও ঝকঝকে ইন্টারফেস',
                    icon: Icons.light_mode_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    isSelected: current == ThemeMode.light,
                    onTap: () {
                      controller.setThemeMode(ThemeMode.light);
                      Get.back();
                    },
                  ),
                  SizedBox(height: 8.h),
                  _buildThemeOption(
                    context: context,
                    title: 'ডার্ক মোড',
                    subtitle: 'চোখের জন্য আরামদায়ক ডার্ক ইন্টারফেস',
                    icon: Icons.dark_mode_rounded,
                    iconColor: const Color(0xFF6366F1),
                    isSelected: current == ThemeMode.dark,
                    onTap: () {
                      controller.setThemeMode(ThemeMode.dark);
                      Get.back();
                    },
                  ),
                  SizedBox(height: 8.h),
                  _buildThemeOption(
                    context: context,
                    title: 'সিস্টেম ডিফল্ট',
                    subtitle: 'আপনার মোবাইল ডিভাইসের থিম অনুসরণ করবে',
                    icon: Icons.brightness_auto_rounded,
                    iconColor: AppColors.primary,
                    isSelected: current == ThemeMode.system,
                    onTap: () {
                      controller.setThemeMode(ThemeMode.system);
                      Get.back();
                    },
                  ),
                ],
              );
            }),

            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: context.isDark ? 0.15 : 0.08)
              : context.surfaceSubtle,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderColor.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.primary : context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primary : context.textMuted.withValues(alpha: 0.5),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
