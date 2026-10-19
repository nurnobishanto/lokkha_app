import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/utils/share_helper.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/app_system/presentation/customer_support/views/customer_support_view.dart';
import 'package:lokkha/shared/widgets/base_webview.dart';
import 'package:lokkha/shared/widgets/theme/theme_toggle_tile.dart';
import 'package:lokkha/features/auth/auth.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(centralAuthStateProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAuth = authState.isLoggedIn || isLoggedIn.value;
    final name = user?.name ?? userName.value?.trim();
    final phone = user?.phone ?? userPhone.value?.trim();
    final isPremium = authState.hasPackage || checkUserHasPackage();

    return Drawer(
      backgroundColor: context.scaffoldColor,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          // ─── Header: Brand & User Info ──────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 18.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LightThemeColors.primaryColor,
                  Color(0xFF1E6B54),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AssetImagePaths.appIcon,
                        height: 36.r,
                        width: 36.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'লক্ষ্য',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'সঠিক পথে, স্বল্প সময়ে',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // User Status Pill / Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: isAuth
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 17.r,
                              backgroundColor: Colors.white,
                              child: Text(
                                (name != null && name.isNotEmpty)
                                    ? name[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: LightThemeColors.primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (name != null && name.isNotEmpty)
                                        ? name
                                        : 'শিক্ষার্থী',
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (phone != null && phone.isNotEmpty)
                                    Text(
                                      phone,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (isPremium)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star,
                                        size: 11.sp, color: Colors.white),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'প্রিমিয়াম',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'স্বাগতম অতিথি!',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'অগ্রগতি সংরক্ষণ করতে লগইন করুন',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                context.pushNamed(Routes.authGateway);
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'লগইন',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: LightThemeColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ─── Menu Items ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: মূল সেবা ও তথ্য
                _buildSectionHeader(context, 'মূল ফিচার ও সাপোর্ট'),
                SizedBox(height: 6.h),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _DrawerMenuTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: LightThemeColors.primaryColor,
                        title: 'আমাদের সম্পর্কে',
                        subtitle: 'লক্ষ্যের গল্প, মিশন ও সাফল্য',
                        onTap: () {
                          Navigator.of(context).pop();
                          context.pushNamed(Routes.about);
                        },
                      ),
                      const Divider(height: 1, indent: 50),
                      _DrawerMenuTile(
                        icon: Icons.headset_mic_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        title: 'কাস্টমার সাপোর্ট',
                        subtitle: 'যেকোনো সহযোগিতার জন্য হেল্পলাইন',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CustomerSupportView(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 50),
                      _DrawerMenuTile(
                        icon: Icons.share_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'শেয়ার করুন',
                        subtitle: 'বন্ধুদের সাথে লক্ষ্য অ্যাপ শেয়ার করুন',
                        onTap: () {
                          final pkg = appPackage.value.isNotEmpty
                              ? appPackage.value
                              : 'com.techyfo.lokkha';
                          final text = Platform.isIOS
                              ? "https://apps.apple.com/us/app/lokkha/id6670564455"
                              : "https://play.google.com/store/apps/details?id=$pkg";
                          ShareHelper.share(
                            text,
                            context: context,
                            subject: 'লক্ষ্য - ক্যারিয়ার প্রস্তুতি অ্যাপ',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // Section 2: থিম সেটিংস
                _buildSectionHeader(context, 'পছন্দসমূহ'),
                SizedBox(height: 6.h),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: const ThemeToggleTile(),
                ),

                SizedBox(height: 14.h),

                // Section 3: নীতিমালা ও শর্তাবলী
                _buildSectionHeader(context, 'নীতিমালা ও শর্তাবলী'),
                SizedBox(height: 6.h),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _DrawerMenuTile(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF10B981),
                        title: 'প্রাইভেসি পলিসি',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BaseWebView(
                              title: "প্রাইভেসি পলিসি",
                              url: Endpoints.privacyPolicy,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 50),
                      _DrawerMenuTile(
                        icon: Icons.payments_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'রিফান্ড পলিসি',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BaseWebView(
                              title: "রিফান্ড পলিসি",
                              url: Endpoints.refundPolicy,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 50),
                      _DrawerMenuTile(
                        icon: Icons.emoji_events_outlined,
                        iconColor: const Color(0xFFF97316),
                        title: 'কন্টেস্ট পলিসি',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BaseWebView(
                              title: "কন্টেস্ট পলিসি",
                              url: Endpoints.contestPolicy,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 50),
                      _DrawerMenuTile(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF64748B),
                        title: 'টার্মস এন্ড কন্ডিশন',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BaseWebView(
                              title: "টার্মস এন্ড কন্ডিশন",
                              url: Endpoints.termsPolicy,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // Section 4: Auth Action (Login or Logout)
                if (isAuth)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: _DrawerMenuTile(
                      icon: Icons.logout_rounded,
                      iconColor: Colors.redAccent,
                      title: 'লগ আউট',
                      titleColor: Colors.redAccent,
                      onTap: () {
                        Navigator.of(context).pop();
                        AuthService.confirmAndLogout();
                      },
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: LightThemeColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: LightThemeColors.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: _DrawerMenuTile(
                      icon: Icons.login_rounded,
                      iconColor: LightThemeColors.primaryColor,
                      title: 'লগইন / রেজিস্ট্রেশন',
                      titleColor: LightThemeColors.primaryColor,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed(Routes.authGateway);
                      },
                    ),
                  ),

                SizedBox(height: 24.h),

                // ─── Footer: Copyright & Version ────────────────────────
                Center(
                  child: Column(
                    children: [
                      Text(
                        '© 2025 Lokkha. All rights reserved.',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: context.textMuted,
                        ),
                      ),
                      if (appVersion.value.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          'ভার্শন ${appVersion.value}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w700,
          color: context.textMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DrawerMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _DrawerMenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 19.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? context.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: context.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: context.textMuted.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
