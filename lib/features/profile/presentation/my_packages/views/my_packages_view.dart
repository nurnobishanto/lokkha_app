import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/core/utils/global.dart';
import '../controllers/my_packages_controller.dart';

class MyPackagesView extends GetView<MyPackagesController> {
  const MyPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'My Packages',
        centerTitle: true,
      ),
      body: Obx(() {
        if (!isLoggedIn.value) {
          return const AuthGatewayView();
        }

        if (controller.apiCallStatus.value == ApiCallStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.apiCallStatus.value == ApiCallStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48.sp,
                  color: const Color(0xFFDC2626),
                ),
                SizedBox(height: 12.h),
                Text(
                  "ডেটা লোড করতে সমস্যা হয়েছে",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: controller.fetchMyPackages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: const Text(
                    "আবার চেষ্টা করুন",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final packages = controller.model.value.packages ?? [];

        return ListView(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 24.h),
          children: [
            // 1. Top Header Card (Matching media_1789896243103.png)
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My Packages",
                          style: TextStyle(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "আমার সাবস্ক্রিপশন প্যাকেজসমূহ",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // নতুন প্যাকেজ Button
                  InkWell(
                    onTap: () => Get.toNamed(Routes.PREMIUM_PACKAGES),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: const Text(
                        "নতুন প্যাকেজ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // 2. Packages List or Empty State
            if (packages.isEmpty)
              _buildEmptyState(context)
            else
              ...packages.map((pkg) {
                final name = pkg.package?.name ?? 'ফিচারসমূহ';
                final startDate = pkg.subscribedAt ?? DateTime.now();
                final endDate = pkg.cancelledAt ?? DateTime.now();
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: PackageCard(
                    name: name,
                    startDate: startDate,
                    endDate: endDate,
                  ),
                );
              }),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF9C3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 32.sp,
              color: const Color(0xFFD97706),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            "আপনার কোনো সক্রিয় প্যাকেজ নেই",
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "সবগুলো আকর্ষণীয় প্রিমিয়াম ফিচার আনলক করতে এখনই আপনার পছন্দের প্যাকেজ বেছে নিন।",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 18.h),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.PREMIUM_PACKAGES),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: const Text(
              "নতুন প্যাকেজ কিনুন",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.onRenew,
  });

  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback? onRenew;

  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  @override
  Widget build(BuildContext context) {
    final startDateStr = DateFormat('dd MMM, yyyy').format(startDate);
    final endDateStr = DateFormat('dd MMM, yyyy').format(endDate);

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (Crown Icon + Title + Status Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Gold Crown Container
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9C3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 22.sp,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    name.isNotEmpty ? name : "ফিচারসমূহ",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),

              // Status Badge (সক্রিয় / মেয়াদ উত্তীর্ণ)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFECACA),
                    width: 1,
                  ),
                ),
                child: Text(
                  isActive ? "সক্রিয়" : "মেয়াদ উত্তীর্ণ",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          Divider(height: 1, color: context.dividerColor),
          SizedBox(height: 14.h),

          // 2. Dates Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                // Start Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 15.sp,
                          color: const Color(0xFF059669),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "শুরু:",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      startDateStr,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Expiry Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15.sp,
                          color: const Color(0xFFEF4444),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "মেয়াদ:",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      endDateStr,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 3. রিনিউ / আপগ্রেড Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRenew ?? () => Get.toNamed(Routes.PREMIUM_PACKAGES),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: const Text(
                "রিনিউ / আপগ্রেড",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
