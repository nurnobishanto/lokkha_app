import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/app_system/app_system.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Build Drawer///");
    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: Column(
        children: <Widget>[
          /// Reduced height for Drawer Header
          70.h.height,
          Image.asset(
            AssetImagePaths.appIcon,
            height: 100,
          ),

          20.h.height,

          /// Drawer Items (standard)
          ListTile(
            visualDensity: VisualDensity.standard,
            leading: const Icon(Icons.info_outline,
                color: LightThemeColors.primaryColor, size: 20),
            title:
                const Text('আমাদের সম্পর্কে', style: TextStyle(fontSize: 14)),
            onTap: () {
              Get.to(
                BaseWebView(title: "আমাদের সম্পর্কে", url: AppConstants.about),
              );
            },
          ),
          const Divider(height: 0.5, color: LightThemeColors.primaryColor),

          ListTile(
            visualDensity: VisualDensity.standard,
            leading: const Icon(Icons.share,
                color: LightThemeColors.primaryColor, size: 20),
            title: const Text(
              'শেয়ার',
              style: TextStyle(fontSize: 14),
            ),
            onTap: () {
              if (Platform.isAndroid) {
                SharePlus.instance.share(
                  ShareParams(
                      text:
                          "https://play.google.com/store/apps/details?id=$appPackage"),
                );
              } else if (Platform.isIOS) {
                SharePlus.instance.share(
                  ShareParams(
                      text:
                          "https://apps.apple.com/us/app/app name/id6670564455"),
                );
              }
            },
          ),
          const Divider(height: 0.5, color: LightThemeColors.primaryColor),

          ListTile(
            visualDensity: VisualDensity.standard,
            leading: const Icon(Icons.headset_mic,
                color: LightThemeColors.primaryColor, size: 20),
            title:
                const Text('কাস্টমার সাপোর্ট', style: TextStyle(fontSize: 14)),
            onTap: () {
              Get.to(const CustomerSupportView());
            },
          ),
          const Divider(height: 0.5, color: LightThemeColors.primaryColor),
          const Divider(height: 0.5, color: LightThemeColors.primaryColor),
          ListTile(
            visualDensity: VisualDensity.standard,
            leading: const Icon(Icons.security,
                color: LightThemeColors.primaryColor, size: 20),
            title:
                const Text('প্রাইভেসি পলিসি', style: TextStyle(fontSize: 14)),
            onTap: () => Get.to(
              () => BaseWebView(
                  title: "প্রাইভেসি পলিসি", url: AppConstants.privacyPolicy),
            ),
          ),
          const Divider(height: 0.5, color: LightThemeColors.primaryColor),

          ListTile(
            visualDensity: VisualDensity.standard,
            leading: const Icon(Icons.payments,
                color: LightThemeColors.primaryColor, size: 20),
            title: const Text('রিফান্ড পলিসি', style: TextStyle(fontSize: 14)),
            onTap: () => Get.to(
              () => BaseWebView(
                  title: "রিফান্ড পলিসি", url: AppConstants.refundPolicy),
            ),
          ),
          const Divider(height: 0.5, color: LightThemeColors.primaryColor),
          ListTile(
            visualDensity: VisualDensity.standard,
            leading: const Icon(Icons.emoji_events,
                color: LightThemeColors.primaryColor, size: 20),
            title: const Text('কন্টেস্ট পলিসি', style: TextStyle(fontSize: 14)),
            onTap: () => Get.to(
              () => BaseWebView(
                  title: "কন্টেস্ট পলিসি", url: AppConstants.contestPolicy),
            ),
          ),
          const Divider(height: .7, color: LightThemeColors.primaryColor),
          ListTile(
            visualDensity: VisualDensity.standard,
            leading: const Icon(Icons.description,
                color: LightThemeColors.primaryColor, size: 20),
            title: const Text('টার্মস এন্ড কন্ডিশন',
                style: TextStyle(fontSize: 14)),
            onTap: () => Get.to(
              () => BaseWebView(
                  title: "টার্মস এন্ড কন্ডিশন", url: AppConstants.termsPolicy),
            ),
          ),
          const Divider(height: 0.5, color: LightThemeColors.primaryColor),
          15.h.height,
          const Spacer(),

          /// App Version (standard)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Center(
              child: Text(
                '© 2025 Lokkha. All rights reserved.',
                style: AppTextStyles.body1.copyWith(fontSize: 11),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Center(
              child: Obx(
                () => Text(
                  'অ্যাপ ভার্শন: ${appVersion.value.isNotEmpty ? appVersion.value : ''}',
                  style: AppTextStyles.body1.copyWith(fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      )
          .paddingSymmetric(horizontal: 10.0.w)
          .paddingOnly(bottom: 20.0.h), // Reduced horizontal padding
    );
  }
}
