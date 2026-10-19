import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/utils/share_helper.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/app_system/presentation/customer_support/views/customer_support_view.dart';
import 'package:lokkha/shared/widgets/base_webview.dart';
import 'package:lokkha/features/auth/auth.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(centralAuthStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAuth = authState.isLoggedIn || isLoggedIn.value;

    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = (screenWidth * 0.82).clamp(300.0, 350.0);
    final topPadding = math.max(MediaQuery.of(context).padding.top, 20.0);

    return Drawer(
      width: drawerWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(24.r),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          // ─── Header: Centered Brand Hero Card ───────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, topPadding + 10.h, 16.w, 24.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF006A4E),
                  Color(0xFF004D38),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Centered Hero Brand Content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AssetImagePaths.appIcon,
                          height: 44.r,
                          width: 44.r,
                        ),
                      ),
                      10.verticalSpace,
                      Text(
                        'লক্ষ্য',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'সঠিক পথে, স্বল্প সময়ে',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // Close Button Top Right
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16.sp,
                      ),
                    ),
                    splashRadius: 18.r,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),

          // ─── Menu Groups ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group 1: মূল ফিচার ও সাপোর্ট
                _buildSectionHeader(context, 'সাপোর্ট'),
                _buildCardGroup(
                  isDark: isDark,
                  children: [
                    _DrawerMenuTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF006A4E),
                      title: 'আমাদের সম্পর্কে',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed(Routes.about);
                      },
                    ),
                    _buildDivider(isDark: isDark),
                    _DrawerMenuTile(
                      icon: Icons.headset_mic_outlined,
                      iconColor: const Color(0xFF2563EB),
                      title: 'কাস্টমার সাপোর্ট',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CustomerSupportView(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(isDark: isDark),
                    _DrawerMenuTile(
                      icon: Icons.share_outlined,
                      iconColor: const Color(0xFFD97706),
                      title: 'শেয়ার করুন',
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

                SizedBox(height: 14.h),

                // Group 2: থিম সেটিংস (Clean Theme Toggle without Chevron)
                _buildSectionHeader(context, 'থিম সেটিংস'),
                _buildCardGroup(
                  isDark: isDark,
                  children: [
                    _DrawerThemeTile(isDark: isDark),
                  ],
                ),

                SizedBox(height: 14.h),

                // Group 3: নীতিমালা ও শর্তাবলী
                _buildSectionHeader(context, 'নীতিমালা ও শর্তাবলী'),
                _buildCardGroup(
                  isDark: isDark,
                  children: [
                    _DrawerMenuTile(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF0D9488),
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
                    _buildDivider(isDark: isDark),
                    _DrawerMenuTile(
                      icon: Icons.receipt_long_outlined,
                      iconColor: const Color(0xFF7C3AED),
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
                    _buildDivider(isDark: isDark),
                    _DrawerMenuTile(
                      icon: Icons.emoji_events_outlined,
                      iconColor: const Color(0xFFEA580C),
                      title: 'কনটেস্ট পলিসি',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BaseWebView(
                            title: "কনটেস্ট পলিসি",
                            url: Endpoints.contestPolicy,
                          ),
                        ),
                      ),
                    ),
                    _buildDivider(isDark: isDark),
                    _DrawerMenuTile(
                      icon: Icons.article_outlined,
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

                SizedBox(height: 16.h),

                // Group 4: Auth Action (Subtle & Clean Logout)
                // Group 4: Auth Action (Subtle & Clean Logout / Login)
                if (isAuth)
                  _buildCardGroup(
                    isDark: isDark,
                    children: [
                      _DrawerMenuTile(
                        icon: Icons.logout_rounded,
                        iconColor: Colors.redAccent,
                        title: 'লগ আউট',
                        titleColor: Colors.redAccent,
                        onTap: () {
                          Navigator.of(context).pop();
                          AuthService.confirmAndLogout();
                        },
                      ),
                    ],
                  )
                else
                  _buildCardGroup(
                    isDark: isDark,
                    children: [
                      _DrawerMenuTile(
                        icon: Icons.login_rounded,
                        iconColor: const Color(0xFF006A4E),
                        title: 'লগইন / রেজিস্ট্রেশন',
                        titleColor: const Color(0xFF006A4E),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.pushNamed(Routes.authGateway);
                        },
                      ),
                    ],
                  ),

                SizedBox(height: 20.h),

                // Footer: Brand Version & Copyright
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'লক্ষ্য',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textMuted,
                            ),
                          ),
                          if (appVersion.value.isNotEmpty) ...[
                            Text(
                              ' • ভার্শন ${appVersion.value}',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: context.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '© 2025 Lokkha. All rights reserved.',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: context.textMuted.withValues(alpha: 0.7),
                        ),
                      ),
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
      padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
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

  Widget _buildCardGroup(
      {required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider({required bool isDark}) {
    return Divider(
      height: 1,
      thickness: 0.6,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFF1F5F9),
      indent: 58.w,
      endIndent: 12.w,
    );
  }
}

class _DrawerMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _DrawerMenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
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
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: (titleColor ?? context.textMuted).withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerThemeTile extends ConsumerWidget {
  final bool isDark;

  const _DrawerThemeTile({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDarkMode = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final accentColor =
        isDarkMode ? const Color(0xFF6366F1) : const Color(0xFFF59E0B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).toggleTheme();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: accentColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ডার্ক মোড',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.82,
                child: Switch.adaptive(
                  value: isDarkMode,
                  activeTrackColor: const Color(0xFF006A4E),
                  activeThumbColor: Colors.white,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
