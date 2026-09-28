import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/theme_controller.dart';
import 'theme_mode_selector_sheet.dart';

/// Reusable Theme Toggle Tile for Drawer, Profile, Settings, etc.
class ThemeToggleTile extends StatelessWidget {
  final bool showSelectorOnTap;
  final EdgeInsetsGeometry? contentPadding;

  const ThemeToggleTile({
    super.key,
    this.showSelectorOnTap = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.to;

    return Obx(() {
      final isDark = controller.isDark.value;
      final modeTitle = controller.currentThemeTitle;

      return ListTile(
        contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF6366F1) : const Color(0xFFF59E0B)).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: isDark ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
            size: 20.sp,
          ),
        ),
        title: Text(
          'থিম ও ডার্ক মোড',
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        subtitle: Text(
          modeTitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: context.textMuted,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: isDark,
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
              onChanged: (_) => controller.toggleTheme(),
            ),
            if (showSelectorOnTap) ...[
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right_rounded,
                color: context.textMuted.withValues(alpha: 0.6),
                size: 20.sp,
              ),
            ],
          ],
        ),
        onTap: () {
          if (showSelectorOnTap) {
            ThemeModeSelectorSheet.show(context);
          } else {
            controller.toggleTheme();
          }
        },
      );
    });
  }
}
