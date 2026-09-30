import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomerSupportView extends GetView {
  const CustomerSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final appInfo = AppUpdateService().appInfo.value?.data;
    final primaryPhone = (appInfo?.contact.primaryPhone.isNotEmpty == true)
        ? appInfo!.contact.primaryPhone
        : '(+880) 1334-260543';
    final fbUrl = appInfo?.socialLinks.facebookPage ?? 'https://facebook.com/lokkhabd';
    final waUrl = appInfo?.socialLinks.whatsappUrl ?? 'https://wa.me/+8801334260543';
    final officeAddress = (appInfo?.contact.address.isNotEmpty == true)
        ? appInfo!.contact.address
        : 'রূপায়ন-লতিফা শামসুদ্দিন স্কয়ার, প্লট: ৩, রোড: ১, মিরপুর ১, ঢাকা - ১২১৬';
    final officeHours = (appInfo?.contact.officeHours.isNotEmpty == true)
        ? appInfo!.contact.officeHours
        : 'সকাল ৯টা - রাত ১০টা';

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(title: 'কাস্টমার সাপোর্ট'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "হটলাইন নম্বর",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => makePhoneCall(primaryPhone),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: OnlineImagePaths.phoneCall,
                      scale: 25.00.r,
                      errorWidget: (_, error, stackTrace) {
                        return const Icon(
                          Icons.phone_in_talk_rounded,
                          color: LightThemeColors.primaryColor,
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      primaryPhone,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: OnlineImagePaths.facebook,
                    scale: 3.0.r,
                    errorWidget: (_, __, stackTrace) {
                      return const Icon(
                        Icons.facebook,
                        color: Colors.blue,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ফেসবুক পেজ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  launchUrlString(fbUrl, mode: LaunchMode.externalApplication);
                },
                child: Container(
                  height: 42,
                  width: 250,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF003277), Color(0xFF002AE8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'বার্তা পাঠান',
                      style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: OnlineImagePaths.whatsApp,
                    scale: 2.8.r,
                    errorWidget: (_, __, stackTrace) {
                      return const Icon(
                        Icons.chat,
                        color: Colors.green,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'অনলাইন সাপোর্ট',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  launchUrlString(waUrl, mode: LaunchMode.externalApplication);
                },
                child: Container(
                  height: 42,
                  width: 250,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00492F), Color(0xFF00A667)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'অনলাইন সাপোর্টে বার্তা পাঠান',
                      style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                appInfo?.contact.officeLabel ?? 'কর্পোরেট অফিস',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  officeAddress,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "অফিস সময়: $officeHours",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.textMuted,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ডেভেলপ করেছে:',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CachedNetworkImage(
                    imageUrl: OnlineImagePaths.techyfo,
                    scale: 4.0.r,
                    errorWidget: (_, __, stackTrace) {
                      return Text(
                        "Techyfo",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'ভার্সন: $appVersion',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrlString(launchUri.toString());
  }
}
