import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/components/custom_app_bar.dart';
import 'package:lokkha/app/components/custom_snackbar.dart';
import 'package:lokkha/app/data/local/my_shared_pref.dart';
import 'package:lokkha/app/helper/global.dart';
import 'package:lokkha/app/modules/auth_views/auth_gateway/views/auth_gateway_view.dart';
import 'package:lokkha/app/routes/app_pages.dart';
import 'package:lokkha/app/views/widgets/web_exam_view.dart';
import 'package:lokkha/comming_soon_view.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/styles/text_style.dart';
import 'package:lokkha/utils/constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardPortalView extends StatelessWidget {
  const DashboardPortalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'শিক্ষার্থী পোর্টাল',
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'মূল প্রোফাইল',
            onPressed: () => Get.toNamed(Routes.PROFILE),
            icon: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
          IconButton(
            tooltip: 'নোটিফিকেশন',
            onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
            icon: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none, size: 18, color: Colors.white),
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Obx(() {
        if (!isLoggedIn.value || MySharedPref.getUserToken().isEmpty) {
          return const AuthGatewayView();
        }

        final user = myUser;
        final referralCode = (user.referralCode != null && user.referralCode!.isNotEmpty)
            ? user.referralCode!
            : "LK${user.userId ?? 'C05189'}";
        final referralLink = "https://lokkha.com/register?ref=$referralCode";

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP STUDENT PROFILE HEADER
              _buildStudentHeader(user, referralCode),

              SizedBox(height: 12.h),

              // 2. 4 TOP STATS (2x2 Grid)
              _buildTopStatsGrid(),

              SizedBox(height: 16.h),

              // 3. আমার মডিউলসমূহ (৬টি মূল মডিউল)
              _buildSectionHeader(
                title: "আমার মডিউলসমূহ",
                badgeText: "৬টি মূল মডিউল",
                icon: Icons.grid_view_rounded,
                iconColor: LightThemeColors.primaryColor,
              ),
              SizedBox(height: 10.h),
              _buildMyModulesGrid(),

              SizedBox(height: 16.h),

              // 4. কুইক প্রস্তুতি ও প্র্যাকটিস শর্টকাট (Unified Container)
              _buildQuickShortcutsCard(),

              SizedBox(height: 16.h),

              // 5. সাবস্ক্রিপশন স্ট্যাটাস কার্ড (VIP Gold Style)
              _buildSubscriptionStatusCard(),

              SizedBox(height: 14.h),

              // 6. সাহায্য ও কাস্টমার সাপোর্ট কার্ড (Clean Native Style - No harsh black!)
              _buildSupportCard(),

              SizedBox(height: 14.h),

              // 7. রেফার ও রিওয়ার্ড কার্ড (Sleek Emerald Brand Card)
              _buildReferAndEarnCard(referralCode, referralLink),

              SizedBox(height: 14.h),

              // 8. মূল বিস্তারিত অ্যাকাউন্ট সেটিংস
              _buildDetailedProfileButton(),
            ],
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. STUDENT HEADER CARD (Lokkha Brand Styled)
  // ---------------------------------------------------------------------------
  Widget _buildStudentHeader(dynamic user, String referralCode) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: LightThemeColors.primaryColor.withValues(alpha: 0.3),
                width: 2.5,
              ),
            ),
            child: buildAvatar(user, radius: 28.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name ?? "User Name",
                        style: AppTextStyles.body1.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (havePackage.value) ...[
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.verified,
                        size: 16.sp,
                        color: LightThemeColors.primaryColor,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 5.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: user.userId ?? referralCode));
                        CustomSnackBar.showCustomToast(message: "আইডি কপি করা হয়েছে!");
                      },
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "আইডি: ${user.userId ?? referralCode}",
                              style: TextStyle(
                                color: const Color(0xFF475569),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(Icons.copy_rounded, size: 10.sp, color: const Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                      decoration: BoxDecoration(
                        color: havePackage.value
                            ? LightThemeColors.primaryColor.withValues(alpha: 0.1)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: havePackage.value
                              ? LightThemeColors.primaryColor.withValues(alpha: 0.25)
                              : const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            havePackage.value ? Icons.workspace_premium_rounded : Icons.school_outlined,
                            size: 11.5.sp,
                            color: havePackage.value
                                ? LightThemeColors.primaryColor
                                : const Color(0xFF64748B),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            havePackage.value ? "প্রিমিয়াম শিক্ষার্থী" : "সাধারণ শিক্ষার্থী",
                            style: TextStyle(
                              color: havePackage.value
                                  ? LightThemeColors.primaryColor
                                  : const Color(0xFF64748B),
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (user.phone != null && user.phone!.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    user.phone!,
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: () => Get.toNamed(Routes.PROFILE_UPDATE),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: LightThemeColors.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: LightThemeColors.primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 17,
                color: LightThemeColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. 4 TOP STATS (2x2 Grid with exact Screenshot Style)
  // ---------------------------------------------------------------------------
  Widget _buildTopStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 2.1,
      children: [
        _buildStatCard(
          icon: const FaIcon(FontAwesomeIcons.graduationCap, color: Color(0xFF059669), size: 18),
          iconBg: const Color(0xFFECFDF5),
          count: "০",
          label: "অংশগ্রহণকৃত পরীক্ষা",
          onTap: () => Get.toNamed(Routes.PROFILE_HISTORY),
        ),
        _buildStatCard(
          icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 22),
          iconBg: const Color(0xFFEFF6FF),
          count: "০",
          label: "সেলফ এক্সাম",
          onTap: () => Get.toNamed(Routes.SELF_EXAM_HISTORY),
        ),
        _buildStatCard(
          icon: const FaIcon(FontAwesomeIcons.trophy, color: Color(0xFFD97706), size: 18),
          iconBg: const Color(0xFFFFFBEB),
          count: "০",
          label: "লাইভ কনটেস্ট",
          onTap: () => Get.toNamed(Routes.CONTEST_HISTORY),
        ),
        _buildStatCard(
          icon: const Icon(Icons.show_chart_rounded, color: Color(0xFF7C3AED), size: 22),
          iconBg: const Color(0xFFF5F3FF),
          count: "০%",
          label: "গড় নির্ভুলতা",
          onTap: () => Get.toNamed(Routes.ACCURACY_PROGRESS),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required Widget icon,
    required Color iconBg,
    required String count,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Center(child: icon),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. আমার মডিউলসমূহ (৬টি মূল মডিউল)
  // ---------------------------------------------------------------------------
  Widget _buildMyModulesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 8.w,
      childAspectRatio: 0.98,
      children: [
        _buildModuleItem(
          title: "My Orders",
          icon: Icons.shopping_bag_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFFEFF6FF),
          badgeColor: const Color(0xFF15803D),
          badgeCount: "0",
          onTap: () => Get.toNamed(Routes.MY_ORDERS),
        ),
        _buildModuleItem(
          title: "My Courses",
          icon: Icons.videocam_rounded,
          iconColor: const Color(0xFFE11D48),
          iconBg: const Color(0xFFFFF1F2),
          badgeColor: const Color(0xFFDC2626),
          badgeCount: "0",
          onTap: () => Get.toNamed(Routes.MY_COURSES),
        ),
        _buildModuleItem(
          title: "My Packages",
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFFFBEB),
          badgeColor: const Color(0xFFD97706),
          badgeCount: "0",
          onTap: () => Get.toNamed(Routes.MY_PACKAGES),
        ),
        _buildModuleItem(
          title: "Self Academy",
          icon: Icons.assignment_turned_in_rounded,
          iconColor: const Color(0xFF0891B2),
          iconBg: const Color(0xFFECFEFF),
          badgeColor: const Color(0xFF0284C7),
          badgeCount: "0",
          onTap: () => Get.toNamed(Routes.SELF_EXAM_HISTORY),
        ),
        _buildModuleItem(
          title: "Exam History",
          icon: Icons.history_rounded,
          iconColor: const Color(0xFF7C3AED),
          iconBg: const Color(0xFFF5F3FF),
          badgeColor: const Color(0xFF16A34A),
          badgeCount: "0",
          onTap: () => Get.toNamed(Routes.PROFILE_HISTORY),
        ),
        _buildModuleItem(
          title: "Content History",
          icon: Icons.military_tech_rounded,
          iconColor: const Color(0xFF4F46E5),
          iconBg: const Color(0xFFEEF2FF),
          badgeColor: const Color(0xFF6366F1),
          badgeCount: "0",
          onTap: () => Get.toNamed(Routes.CONTEST_HISTORY),
        ),
      ],
    );
  }

  Widget _buildModuleItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color badgeColor,
    required String badgeCount,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46.r,
                    height: 46.r,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Icon(icon, color: iconColor, size: 22.r),
                    ),
                  ),
                  Positioned(
                    top: -3.h,
                    right: -3.w,
                    child: Container(
                      width: 17.r,
                      height: 17.r,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. কুইক প্রস্তুতি ও প্র্যাকটিস শর্টকাট (Master Card Container)
  // ---------------------------------------------------------------------------
  Widget _buildQuickShortcutsCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: LightThemeColors.primaryColor,
                  size: 18,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "কুইক প্রস্তুতি ও প্র্যাকটিস শর্টকাট",
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.95,
            children: [
              _buildShortcutItem(
                title: "বিষয়ভিত্তিক\nপরীক্ষা",
                icon: const Icon(Icons.menu_book_rounded, color: Color(0xFF10B981), size: 20),
                iconBg: const Color(0xFFE8F8F2),
                onTap: () => Get.toNamed(Routes.EXAM_CATEGORY),
              ),
              _buildShortcutItem(
                title: "লাইভ\nকনটেস্ট",
                icon: const FaIcon(FontAwesomeIcons.trophy, color: Color(0xFFD97706), size: 18),
                iconBg: const Color(0xFFFFFBEB),
                onTap: () => Get.toNamed(Routes.ALL_CONTEST),
              ),
              _buildShortcutItem(
                title: "অনলাইন\nকোর্স",
                icon: const Icon(Icons.videocam_rounded, color: Color(0xFFE11D48), size: 20),
                iconBg: const Color(0xFFFFF1F2),
                onTap: () => Get.toNamed(Routes.ALL_COURSES),
              ),
              _buildShortcutItem(
                title: "প্রিমিয়াম\nপ্যাকেজ",
                icon: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFEA580C), size: 20),
                iconBg: const Color(0xFFFFF7ED),
                onTap: () => Get.toNamed(Routes.PREMIUM_PACKAGES),
              ),
              _buildShortcutItem(
                title: "নিয়োগ\nবিজ্ঞপ্তি",
                icon: const Icon(Icons.business_center_rounded, color: Color(0xFF2563EB), size: 20),
                iconBg: const Color(0xFFEFF6FF),
                onTap: () => Get.toNamed(Routes.JOBS),
              ),
              _buildShortcutItem(
                title: "সাম্প্রতিক\nতথ্য",
                icon: const Icon(Icons.public_rounded, color: Color(0xFF0D9488), size: 20),
                iconBg: const Color(0xFFF0FDFA),
                onTap: () => Get.toNamed(Routes.CURRENT_AFFAIRS),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem({
    required String title,
    required Widget icon,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFEEF2F6), width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(child: icon),
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. সাবস্ক্রিপশন স্ট্যাটাস কার্ড (High-End VIP Champagne / Gold Style)
  // ---------------------------------------------------------------------------
  Widget _buildSubscriptionStatusCard() {
    return Obx(() {
      final bool isPremium = havePackage.value;

      return Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isPremium ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
            width: isPremium ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isPremium
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFD97706),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "সাবস্ক্রিপশন স্ট্যাটাস",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isPremium
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPremium ? Icons.verified : Icons.lock_outline_rounded,
                        size: 12.sp,
                        color: isPremium ? const Color(0xFF059669) : const Color(0xFF64748B),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isPremium ? "Active Premium" : "Free Plan",
                        style: TextStyle(
                          color: isPremium ? const Color(0xFF059669) : const Color(0xFF64748B),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              isPremium
                  ? "আপনার প্রিমিয়াম সাবস্ক্রিপশন সক্রিয় রয়েছে। সকল লাইভ পরীক্ষা, কোর্স ও এক্সক্লুসিভ ফিচার আনলকড।"
                  : "আনলিমিটেড বিষয়ভিত্তিক পরীক্ষা ও এক্সক্লুসিভ মডেল টেস্ট দিতে আজই প্রিমিয়াম সাবস্ক্রিপশন গ্রহণ করুন।",
              style: TextStyle(
                fontSize: 12.5.sp,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            SizedBox(height: 14.h),
            InkWell(
              onTap: () => Get.toNamed(Routes.PREMIUM_PACKAGES),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPremium
                        ? [const Color(0xFF059669), const Color(0xFF10B981)]
                        : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: (isPremium ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPremium ? Icons.refresh_rounded : Icons.bolt_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      isPremium ? "প্যাকেজ রিনিউ বা আপগ্রেড করুন" : "প্রিমিয়ামে আপগ্রেড করুন",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 6. যেকোনো সহায়তায় কার্ড (Friendly, Clean Native Look - No Dark Block!)
  // ---------------------------------------------------------------------------
  Widget _buildSupportCard() {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: LightThemeColors.primaryColor,
                  size: 22,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "সাহায্য ও সাপোর্ট সেন্টার",
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "যেকোনো প্রশ্ন বা সমস্যায় আমরা আপনার পাশে আছি",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _launchURL("https://wa.me/8801332804290"),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(FontAwesomeIcons.whatsapp, size: 16, color: Color(0xFF16A34A)),
                        SizedBox(width: 8.w),
                        Text(
                          "হোয়াটসঅ্যাপ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: InkWell(
                  onTap: () => _launchURL("https://m.me/lokkhabd"),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.facebookMessenger,
                          color: Color(0xFF2563EB),
                          size: 16,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "মেসেঞ্জার",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. REFER & EARN CARD (Sleek Lokkha Emerald Brand Card)
  // ---------------------------------------------------------------------------
  Widget _buildReferAndEarnCard(String referralCode, String referralLink) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF19614C),
            Color(0xFF238466),
            Color(0xFF2A8D6F),
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A8D6F).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Color(0xFFFDE68A),
                      size: 17,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "রেফার করুন ও পয়েন্ট জিতুন",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: referralCode));
                  CustomSnackBar.showCustomToast(message: "রেফার কোড কপি করা হয়েছে!");
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        referralCode,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      const Icon(Icons.copy_rounded, size: 10, color: Colors.black87),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            "বন্ধুদের আমন্ত্রণ জানান এবং প্রতিটি সফল রেজিস্ট্রেশনে পান ১০০ রিওয়ার্ড পয়েন্ট।",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_rounded, size: 13, color: Color(0xFFFDE68A)),
                    SizedBox(width: 5.w),
                    Text(
                      "রেফার্ড: ০ জন",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, size: 13, color: Color(0xFFFDE68A)),
                    SizedBox(width: 5.w),
                    Text(
                      "অর্জিত: +০ Pts",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Get.to(const ComingSoonPage()),
                child: Text(
                  "লিস্ট দেখুন →",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Copy Link Field
          Container(
            padding: EdgeInsets.fromLTRB(12.w, 3.h, 3.w, 3.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralLink,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: referralLink));
                    CustomSnackBar.showCustomToast(message: "রেফারেল লিংক কপি করা হয়েছে!");
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: LightThemeColors.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text(
                          "কপি লিংক",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Social share row
          Row(
            children: [
              Text(
                "শেয়ার করুন:",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 10.w),
              _buildShareIcon(
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 15),
                bgColor: const Color(0xFF22C55E),
                onTap: () => _launchURL("whatsapp://send?text=${Uri.encodeComponent('Join Lokkha: $referralLink')}"),
              ),
              SizedBox(width: 8.w),
              _buildShareIcon(
                icon: const FaIcon(FontAwesomeIcons.facebookF, color: Colors.white, size: 13),
                bgColor: const Color(0xFF1877F2),
                onTap: () => SharePlus.instance.share(
                  ShareParams(text: "Join Lokkha: $referralLink"),
                ),
              ),
              SizedBox(width: 8.w),
              _buildShareIcon(
                icon: const FaIcon(FontAwesomeIcons.telegram, color: Colors.white, size: 13),
                bgColor: const Color(0xFF0284C7),
                onTap: () => _launchURL("https://t.me/share/url?url=${Uri.encodeComponent(referralLink)}"),
              ),
              SizedBox(width: 8.w),
              _buildShareIcon(
                icon: const Icon(Icons.share_rounded, color: Colors.white, size: 15),
                bgColor: Colors.white.withValues(alpha: 0.25),
                onTap: () => SharePlus.instance.share(
                  ShareParams(text: "Join Lokkha: $referralLink"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareIcon({
    required Widget icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. LINK TO OLD DETAILED PROFILE
  // ---------------------------------------------------------------------------
  Widget _buildDetailedProfileButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () => Get.toNamed(Routes.PROFILE),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.r),
                decoration: BoxDecoration(
                  color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.manage_accounts_rounded,
                  color: LightThemeColors.primaryColor,
                  size: 22,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "বিস্তারিত অ্যাকাউন্ট সেটিংস",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "ব্যক্তিগত তথ্য, পাসওয়ার্ড পরিবর্তন ও সেটিংস দেখতে চাপুন",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 15),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader({
    required String title,
    String? badgeText,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: iconColor, size: 16.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        if (badgeText != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.showCustomErrorToast(message: "লিংকটি ওপেন করা সম্ভব হয়নি");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}
