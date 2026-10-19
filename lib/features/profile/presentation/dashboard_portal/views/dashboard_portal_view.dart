import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../riverpod/dashboard_portal_notifier.dart';

class DashboardPortalView extends ConsumerStatefulWidget {
  const DashboardPortalView({super.key});

  @override
  ConsumerState<DashboardPortalView> createState() => _DashboardPortalViewState();
}

class _DashboardPortalViewState extends ConsumerState<DashboardPortalView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardPortalNotifierProvider.notifier).fetchDashboardOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardPortalNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'প্রোফাইল',
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (!isLoggedIn.value) {
            return const AuthGatewayView();
          }

          final user = myUser;
          final refData = dashboardState.referral;
          final referralCode =
              (refData?.referralCode != null && refData!.referralCode!.isNotEmpty)
                  ? refData.referralCode!
                  : ((user.referralCode != null && user.referralCode!.isNotEmpty)
                      ? user.referralCode!
                      : "LK${user.userId ?? 'C05189'}");
          return RefreshIndicator(
            onRefresh: () => ref.read(dashboardPortalNotifierProvider.notifier).refreshDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP STUDENT PROFILE HEADER (Compact, Clean Emerald Brand Card)
                  _buildStudentHeader(context, user, referralCode, dashboardState),

                  SizedBox(height: 10.h),

                  // 2. 4 TOP STATS (Unified 2x2 Analytics Card)
                  _buildTopStatsGrid(context, dashboardState),

                  SizedBox(height: 14.h),

                  // 3. আমার মডিউলসমূহ (৬টি মূল মডিউল)
                  _buildSectionHeader(
                    context,
                    title: "আমার মডিউলসমূহ",
                    icon: Icons.grid_view_rounded,
                    iconColor: context.primaryColor,
                  ),
                  SizedBox(height: 12.h),
                  _buildMyModulesGrid(context, dashboardState),

                  SizedBox(height: 16.h),

                  // 4. সাহায্য ও কাস্টমার সাপোর্ট কার্ড
                  _buildSupportCard(context),

                  SizedBox(height: 10.h),

                  // 5. মূল বিস্তারিত অ্যাকাউন্ট সেটিংস
                  _buildDetailedProfileButton(context),

                  SizedBox(height: 6.h),

                  // 6. লগ আউট বাটন
                  _buildLogoutButton(context),
                ],
              ),
            ),
          );
    },
  ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. STUDENT HEADER CARD (Clean, Minimal, Professional Emerald Card)
  // ---------------------------------------------------------------------------
  Widget _buildStudentHeader(
    BuildContext context,
    dynamic user,
    String referralCode,
    DashboardPortalState controller,
  ) {
    final packageName = controller.subscription?.packageName;
    final rewardPoints = controller.rewards?.balance ?? user.rewardPoints ?? user.points ?? 0;
    final userId = user.userId ?? referralCode;
    final badgeTitle = (packageName != null && packageName.isNotEmpty)
        ? packageName
        : (controller.subscription != null ? "ফিচারসমূহ" : null);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF065F46),
            Color(0xFF047857),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with clean verified badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 1.8,
                      ),
                    ),
                    child: buildAvatar(user, radius: 22.r),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 8.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),

              // Name, Package, ID & Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name + Crown/Package Badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name ?? "sadman",
                            style: TextStyle(
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeTitle != null && badgeTitle.isNotEmpty) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 0.7,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  size: 10.5.sp,
                                  color: const Color(0xFFFDE68A),
                                ),
                                SizedBox(width: 2.5.w),
                                Text(
                                  badgeTitle,
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),

                    // Row 2: ID + Phone (Clean Single Line)
                    Row(
                      children: [
                        // ID Chip with Copy
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: "$userId"));
                            CustomSnackBar.showCustomToast(message: "আইডি কপি করা হয়েছে!");
                          },
                          borderRadius: BorderRadius.circular(5.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.5.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "ID: $userId",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                                ),
                                SizedBox(width: 2.5.w),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 9.sp,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Phone
                        if (user.phone != null && user.phone.toString().isNotEmpty) ...[
                          Text(
                            " • ",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10.sp,
                            ),
                          ),
                          Icon(
                            Icons.call_rounded,
                            size: 10.sp,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 2.w),
                          Flexible(
                            child: Text(
                              "${user.phone}",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Bottom Action Row: Ultra-compact, Symmetrical Frosted Glass Pills
          Row(
            children: [
              // Left: Points Pill
              Expanded(
                child: InkWell(
                  onTap: () => context.push(Routes.referral),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 13.5.sp,
                          color: const Color(0xFFFDE68A),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "$rewardPoints পয়েন্ট",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 13.sp,
                          color: Colors.white60,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Right: Profile Edit Button
              Expanded(
                child: InkWell(
                  onTap: () => context.push(Routes.profileUpdate),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "প্রোফাইল এডিট",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
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
  // 2. 4 TOP STATS (Unified 2x2 Analytics Card - Minimal & Clean)
  // ---------------------------------------------------------------------------
  Widget _buildTopStatsGrid(BuildContext context, DashboardPortalState controller) {
    final counts = controller.counts;
    final perf = controller.performance;

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildUnifiedStatCell(
                  context: context,
                  icon: const FaIcon(FontAwesomeIcons.graduationCap,
                      color: Color(0xFF059669), size: 16),
                  iconBg: context.isDark
                      ? const Color(0xFF059669).withValues(alpha: 0.18)
                      : const Color(0xFFECFDF5),
                  count: "${counts?.totalExams ?? 0}",
                  label: "অংশগ্রহণকৃত পরীক্ষা",
                  onTap: () => context.push(Routes.profileHistory),
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: context.borderColor.withValues(alpha: 0.7),
              ),
              Expanded(
                child: _buildUnifiedStatCell(
                  context: context,
                  icon: Icon(Icons.edit_note_rounded,
                      color: const Color(0xFF2563EB), size: 21.sp),
                  iconBg: context.isDark
                      ? const Color(0xFF2563EB).withValues(alpha: 0.18)
                      : const Color(0xFFEFF6FF),
                  count: "${counts?.totalSelfExams ?? 0}",
                  label: "সেলফ এক্সাম",
                  onTap: () => context.push(Routes.selfExamHistory),
                ),
              ),
            ],
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: context.borderColor.withValues(alpha: 0.7),
          ),
          Row(
            children: [
              Expanded(
                child: _buildUnifiedStatCell(
                  context: context,
                  icon: const FaIcon(FontAwesomeIcons.trophy,
                      color: Color(0xFFD97706), size: 15),
                  iconBg: context.isDark
                      ? const Color(0xFFD97706).withValues(alpha: 0.18)
                      : const Color(0xFFFFFBEB),
                  count: "${counts?.totalContests ?? 0}",
                  label: "লাইভ কনটেস্ট",
                  onTap: () => context.push(Routes.liveContest),
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: context.borderColor.withValues(alpha: 0.7),
              ),
              Expanded(
                child: _buildUnifiedStatCell(
                  context: context,
                  icon: Icon(Icons.show_chart_rounded,
                      color: const Color(0xFF7C3AED), size: 21.sp),
                  iconBg: context.isDark
                      ? const Color(0xFF7C3AED).withValues(alpha: 0.18)
                      : const Color(0xFFF5F3FF),
                  count: "${(perf?.accuracyRate ?? 0).toStringAsFixed(1)}%",
                  label: "গড় নির্ভুলতা",
                  onTap: () => context.push(Routes.accuracyProgress),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedStatCell({
    required BuildContext context,
    required Widget icon,
    required Color iconBg,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: context.isDark ? iconBg.withValues(alpha: 0.15) : iconBg,
                borderRadius: BorderRadius.circular(11.r),
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
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.textMuted,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. আমার মডিউলসমূহ (৬টি মূল মডিউল - Colorful Pastel Grid)
  // ---------------------------------------------------------------------------
  Widget _buildMyModulesGrid(BuildContext context, DashboardPortalState controller) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10.h,
      crossAxisSpacing: 10.w,
      childAspectRatio: 1.05,
      children: [
        _buildModuleItem(
          context: context,
          title: "My Orders",
          icon: Icons.shopping_bag_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBg: context.isDark
              ? const Color(0xFF2563EB).withValues(alpha: 0.18)
              : const Color(0xFFEFF6FF),
          onTap: () => context.push(Routes.myOrders),
        ),
        _buildModuleItem(
          context: context,
          title: "My Courses",
          icon: Icons.smart_display_rounded,
          iconColor: const Color(0xFFE11D48),
          iconBg: context.isDark
              ? const Color(0xFFE11D48).withValues(alpha: 0.18)
              : const Color(0xFFFFF1F2),
          onTap: () => context.push(Routes.myCourses),
        ),
        _buildModuleItem(
          context: context,
          title: "My Packages",
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFFD97706),
          iconBg: context.isDark
              ? const Color(0xFFD97706).withValues(alpha: 0.18)
              : const Color(0xFFFFFBEB),
          onTap: () => context.push(Routes.myPackages),
        ),
        _buildModuleItem(
          context: context,
          title: "Self Academy",
          icon: Icons.assignment_turned_in_rounded,
          iconColor: const Color(0xFF0891B2),
          iconBg: context.isDark
              ? const Color(0xFF0891B2).withValues(alpha: 0.18)
              : const Color(0xFFECFEFF),
          onTap: () => context.push(Routes.selfExamHistory),
        ),
        _buildModuleItem(
          context: context,
          title: "Exam History",
          icon: Icons.history_rounded,
          iconColor: const Color(0xFF7C3AED),
          iconBg: context.isDark
              ? const Color(0xFF7C3AED).withValues(alpha: 0.18)
              : const Color(0xFFF5F3FF),
          onTap: () => context.push(Routes.profileHistory),
        ),
        _buildModuleItem(
          context: context,
          title: "Content History",
          icon: Icons.military_tech_rounded,
          iconColor: const Color(0xFF059669),
          iconBg: context.isDark
              ? const Color(0xFF059669).withValues(alpha: 0.18)
              : const Color(0xFFECFDF5),
          onTap: () => context.push(Routes.contestHistory),
        ),
      ],
    );
  }

  Widget _buildModuleItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: context.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: context.isDark
                    ? Colors.black.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? iconBg.withValues(alpha: 0.15)
                      : iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 22.r),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF0D9488).withValues(alpha: 0.18)
                      : const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Color(0xFF0D9488),
                  size: 19,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "সাহায্য ও সাপোর্ট সেন্টার",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _launchURL("https://wa.me/8801332804290"),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.25)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.isDark
                            ? const Color(0xFF059669).withValues(alpha: 0.4)
                            : const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(FontAwesomeIcons.whatsapp,
                            size: 15, color: Color(0xFF16A34A)),
                        SizedBox(width: 7.w),
                        Text(
                          "হোয়াটসঅ্যাপ",
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.bold,
                            color: context.isDark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: InkWell(
                  onTap: () => _launchURL("https://m.me/lokkhabd"),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.25)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.isDark
                            ? const Color(0xFF2563EB).withValues(alpha: 0.4)
                            : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.facebookMessenger,
                          color: Color(0xFF2563EB),
                          size: 15,
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          "মেসেঞ্জার",
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.bold,
                            color: context.isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF1D4ED8),
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
  // 5. ACCOUNT SETTINGS TILE (Compact & Professional)
  // ---------------------------------------------------------------------------
  Widget _buildDetailedProfileButton(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () => context.push(Routes.settings),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.borderColor, width: 0.9),
            boxShadow: [
              BoxShadow(
                color: context.isDark
                    ? Colors.black.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF2563EB).withValues(alpha: 0.18)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.settings_suggest_rounded,
                  color: const Color(0xFF2563EB),
                  size: 17.5.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "অ্যাকাউন্ট সেটিংস",
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.textMuted,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. LOGOUT BUTTON (Compact & Professional)
  // ---------------------------------------------------------------------------
  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.red.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () => AuthService.confirmAndLogout(),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.18),
              width: 0.9,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 16.5.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "লগ আউট",
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.redAccent.withValues(alpha: 0.7),
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader(
    BuildContext context, {
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
              width: 3.5.w,
              height: 15.h,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        if (badgeText != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
            decoration: BoxDecoration(
              color: context.isDark
                  ? context.surfaceColor
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 10.5.sp,
                color: context.textMuted,
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
        CustomSnackBar.showCustomErrorToast(
            message: "লিংকটি ওপেন করা সম্ভব হয়নি");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}
