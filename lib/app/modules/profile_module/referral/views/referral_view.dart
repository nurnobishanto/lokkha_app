import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../../../../components/custom_app_bar.dart';
import '../../../../helper/global.dart';
import '../../../auth_views/auth_gateway/views/auth_gateway_view.dart';
import '../controllers/referral_controller.dart';

class ReferralView extends GetView<ReferralController> {
  const ReferralView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'আমার রেফারেল',
        centerTitle: true,
      ),
      body: Obx(() {
        if (!isLoggedIn.value) {
          return const AuthGatewayView();
        }

        final code = controller.referralCode.value;
        final link = controller.referralLink.value;
        final totalInvited = controller.totalInvited.value;
        final earnedPoints = controller.earnedPoints.value;
        final successful = controller.successfulReferrals.value;
        final users = controller.referredUsers;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 28.h),
          children: [
            // -----------------------------------------------------------------
            // 1. TOP HEADER CARD (Matching media_1789897121729.png)
            // -----------------------------------------------------------------
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: context.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Back Button
                      InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 18.sp,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "আমার রেফারেল",
                              style: TextStyle(
                                fontSize: 16.5.sp,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "বন্ধুদের আমন্ত্রণ জানান ও রিওয়ার্ড পয়েন্ট অর্জন করুন",
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: context.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // রিওয়ার্ড পয়েন্ট Pill Button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFF059669),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          size: 15.sp,
                          color: const Color(0xFFF59E0B),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          "রিওয়ার্ড পয়েন্ট",
                          style: TextStyle(
                            color: const Color(0xFF059669),
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // -----------------------------------------------------------------
            // 2. 3 SUMMARY STAT CARDS IN A ROW
            // -----------------------------------------------------------------
            Row(
              children: [
                // 1. সর্বমোট আমন্ত্রিত
                Expanded(
                  child: _buildSummaryStatCard(
                    context: context,
                    icon: Icons.person_add_alt_1_rounded,
                    iconBg: const Color(0xFFDCFCE7),
                    iconColor: const Color(0xFF16A34A),
                    value: "$totalInvited",
                    label: "সর্বমোট আমন্ত্রিত",
                  ),
                ),
                SizedBox(width: 8.w),

                // 2. অর্জিত পয়েন্ট
                Expanded(
                  child: _buildSummaryStatCard(
                    context: context,
                    icon: Icons.monetization_on_rounded,
                    iconBg: const Color(0xFFFEF9C3),
                    iconColor: const Color(0xFFD97706),
                    value: "+$earnedPoints",
                    valueColor: const Color(0xFF059669),
                    label: "অর্জিত পয়েন্ট",
                  ),
                ),
                SizedBox(width: 8.w),

                // 3. সফল রেফারেল
                Expanded(
                  child: _buildSummaryStatCard(
                    context: context,
                    icon: Icons.check_circle_rounded,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    value: "$successful",
                    label: "সফল রেফারেল",
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // -----------------------------------------------------------------
            // 3. EMERALD REFERRAL ACTION CARD
            // -----------------------------------------------------------------
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A5C43),
                    Color(0xFF0B6349),
                    Color(0xFF0F6E52),
                  ],
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A5C43).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Badges
                  Row(
                    children: [
                      // Referral Code Badge
                      InkWell(
                        onTap: controller.copyReferralCode,
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            "রেফারেল কোড: $code",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Points Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          "+১০০ পয়েন্ট প্রতি রেফারেল",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Headline
                  Text(
                    "বন্ধুদের রেফার করুন এবং পয়েন্ট জিতে নিন!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Subtitle
                  Text(
                    "আপনার রেফারেল লিঙ্ক দিয়ে কেউ নতুন একাউন্ট তৈরি করলেই আপনার ওয়ালেটে সাথে সাথে যুক্ত হবে ১০০ রিওয়ার্ড পয়েন্ট।",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11.5.sp,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Link Box with Copy Button
                  Container(
                    padding: EdgeInsets.fromLTRB(14.w, 4.h, 4.w, 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            link,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        InkWell(
                          onTap: controller.copyReferralLink,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE67E22),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  "কপি করুন",
                                  style: TextStyle(
                                    fontSize: 12.sp,
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

                  // Social Share Row
                  Row(
                    children: [
                      Text(
                        "সোশ্যালে শেয়ার করুন:",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      _buildSocialBtn(
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 16,
                        ),
                        bgColor: const Color(0xFF25D366),
                        onTap: controller.shareWhatsApp,
                      ),
                      SizedBox(width: 10.w),
                      _buildSocialBtn(
                        icon: const FaIcon(
                          FontAwesomeIcons.facebookF,
                          color: Colors.white,
                          size: 15,
                        ),
                        bgColor: const Color(0xFF1877F2),
                        onTap: controller.shareFacebook,
                      ),
                      SizedBox(width: 10.w),
                      _buildSocialBtn(
                        icon: const FaIcon(
                          FontAwesomeIcons.telegram,
                          color: Colors.white,
                          size: 15,
                        ),
                        bgColor: const Color(0xFF229ED9),
                        onTap: controller.shareTelegram,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // -----------------------------------------------------------------
            // 4. SECTION HEADER: রেফারেল তালিকা (Referred Users)
            // -----------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        size: 16.sp,
                        color: const Color(0xFF059669),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "রেফারেল তালিকা (Referred Users)",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  "সর্বমোট: ${users.length} জন",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // -----------------------------------------------------------------
            // 5. REFERRED USERS LIST / EMPTY STATE
            // -----------------------------------------------------------------
            if (users.isEmpty)
              _buildEmptyState(context)
            else
              ...users.map((u) => _buildReferredUserCard(u, context)),
          ],
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY STAT CARD WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildSummaryStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    Color? valueColor,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, color: iconColor, size: 17.sp),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? context.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SOCIAL BUTTON WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildSocialBtn({
    required Widget icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58.r,
            height: 58.r,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.center_focus_weak_rounded,
              size: 30.sp,
              color: const Color(0xFF059669),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "এখনও কোনো রেফারেল নেই",
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "আপনার রেফারেল লিঙ্ক বন্ধুদের সাথে শেয়ার করুন এবং প্রতি সফল নিবন্ধনে ১০০ রিওয়ার্ড পয়েন্ট জিতে নিন।",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: context.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REFERRED USER CARD WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildReferredUserCard(dynamic user, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: context.textSecondary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'ব্যবহারকারী',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  user['date'] ?? '',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              "+১০০ Pts",
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
