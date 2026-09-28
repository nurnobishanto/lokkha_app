import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/components/custom_app_bar.dart';
import 'package:lokkha/app/components/custom_snackbar.dart';
import '../../../../../utils/constants.dart';
import '../../../../helper/global.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/api_call_status.dart';
import '../../../../views/widgets/web_exam_view.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import 'package:lokkha/app/components/theme/theme_toggle_tile.dart';
import '../../../auth_views/auth_gateway/views/auth_gateway_view.dart';
import '../../../drawer_pages/views/customer_support_view.dart';
import '../../widgets/devices_management_sheet.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'প্রোফাইল',
        centerTitle: true,
      ),
      body: Obx(() {
        final status = controller.profileApiStatus.value;
        final profileData = myUser;
        if (status == ApiCallStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!isLoggedIn.value) {
          return const AuthGatewayView();
        }

        if (status == ApiCallStatus.error) {
          return const Center(child: Text("তথ্য লোড করা সম্ভব হয়নি"));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER CARD (Matching media_1789898866331.png) ---
              Container(
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
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Row: Avatar + User Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar with checkmark badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.2,
                                ),
                              ),
                              child: buildAvatar(profileData, radius: 32.r),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(3.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 11.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 14.w),

                        // Name, Feature Badge, ID & Phone
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: Name + Crown Badge
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      profileData.name ?? "sadman",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 9.w,
                                      vertical: 3.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.workspace_premium_rounded,
                                          size: 13.sp,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "ফিচারসমূহ",
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),

                              // Row 2: ID + Phone
                              Row(
                                children: [
                                  // White ID Box
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                        text: profileData.userId ?? "",
                                      ));
                                      CustomSnackBar.showCustomToast(
                                        message: "আইডি কপি করা হয়েছে!",
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        "ID: ${profileData.userId ?? '250500049'}",
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),

                                  // Phone Icon + Number
                                  Icon(
                                    Icons.call_rounded,
                                    size: 13.sp,
                                    color: const Color(0xFF6EE7B7),
                                  ),
                                  SizedBox(width: 4.w),
                                  Flexible(
                                    child: Text(
                                      profileData.phone ?? "8801749784788",
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w500,
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
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Bottom Row: Points Pill + Edit Profile Button
                    Row(
                      children: [
                        // Left: 90 পয়েন্ট >
                        InkWell(
                          onTap: () => Get.toNamed(Routes.REFERRAL),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.monetization_on_rounded,
                                  size: 16.sp,
                                  color: const Color(0xFFF59E0B),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  "${profileData.points ?? 90} পয়েন্ট",
                                  style: TextStyle(
                                    color: const Color(0xFFFDE68A),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16.sp,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

                        // Right: প্রোফাইল এডিট
                        InkWell(
                          onTap: () => Get.toNamed(Routes.PROFILE_UPDATE),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.manage_accounts_rounded,
                                  size: 16.sp,
                                  color: const Color(0xFF064E3B),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  "প্রোফাইল এডিট",
                                  style: TextStyle(
                                    color: const Color(0xFF064E3B),
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),
              _buildSectionLabel("আপনার ড্যাশবোর্ড"),

              // --- GRID OPTIONS ---
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
                childAspectRatio: 2,
                children: [
                  _buildGridItem(
                    onTap: () => Get.toNamed(Routes.MY_PACKAGES),
                    text: 'আমার প্যাকেজ',
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                  ),
                  _buildGridItem(
                    onTap: () => Get.toNamed(Routes.MY_COURSES),
                    text: 'আমার কোর্স',
                    icon: Icons.school,
                    color: Colors.purple,
                  ),
                  _buildGridItem(
                    onTap: () => Get.to(WebExamView(
                        title: "Favourite Question",
                        url: AppConstants.myQuestions)),
                    text: 'ফেভারিট প্রশ্ন',
                    icon: Icons.favorite,
                    color: Colors.redAccent,
                  ),
                  _buildGridItem(
                    onTap: () => Get.toNamed(Routes.MY_ORDERS),
                    text: 'আমার অর্ডারস',
                    icon: Icons.receipt_long,
                    color: Colors.teal,
                  ),
                ],
              ),

              SizedBox(height: 24.h),
              _buildSectionLabel("অন্যান্য"),

              // --- LIST OPTIONS ---
              Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.r),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    const ThemeToggleTile(),
                    const Divider(height: 0, indent: 50),
                    _buildListItem(
                      onTap: () => DevicesManagementSheet.show(context),
                      text: 'লগইন ডিভাইস সমূহ',
                      icon: Icons.devices_rounded,
                      color: const Color(0xFF0F6E52),
                    ),
                    const Divider(height: 0, indent: 50),
                    _buildListItem(
                      onTap: () {
                        Get.defaultDialog(
                          title: "অ্যাকাউন্ট ডিলিট",
                          middleText: "কাস্টমার সার্ভিসের সাথে যোগাযোগ করুন।",
                          onConfirm: () {
                            Get.back();
                            Get.to(const CustomerSupportView());
                          },
                        );
                      },
                      text: 'অ্যাকাউন্ট ডিলিট করুন',
                      icon: Icons.delete_forever,
                      color: Colors.red,
                    ),
                    const Divider(height: 0, indent: 50),
                    _buildListItem(
                      onTap: () {
                        Get.defaultDialog(
                          title: "লগ আউট",
                          titleStyle: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                          middleText: "আপনি কি নিশ্চিতভাবে লগ আউট করতে চান?",
                          middleTextStyle: TextStyle(fontSize: 14.sp),
                          textConfirm: "হ্যাঁ",
                          textCancel: "না",
                          confirmTextColor: Colors.white,
                          cancelTextColor: Colors.black,
                          buttonColor: Colors.redAccent,
                          onConfirm: () {
                            Get.back();
                            controller.logout();
                          },
                        );
                      },
                      text: 'লগ আউট',
                      icon: Icons.logout,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridItem({
    required VoidCallback onTap,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Builder(
      builder: (context) {
        return Material(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 18.sp),
                  SizedBox(height: 8.h),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem({
    required VoidCallback onTap,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Builder(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: onTap,
            leading: Icon(icon, color: color, size: 18.sp),
            title: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            trailing: Icon(Icons.chevron_right, size: 20, color: context.textMuted),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          ),
        );
      },
    );
  }
}
