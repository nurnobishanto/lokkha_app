import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/routes/routes.dart';
import '../controllers/maintenance_mode_view_controller.dart';

class MaintenanceModeView extends GetView<MaintenanceModeController> {
  final String? title;
  final String? message;

  const MaintenanceModeView({super.key, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ??
        (Get.arguments is Map ? Get.arguments['title'] : null) ??
        'অ্যাপ রক্ষণাবেক্ষণ চলছে';
    final displayMessage = message ??
        (Get.arguments is Map ? Get.arguments['message'] : null) ??
        'আমাদের সিস্টেম আপগ্রেডেশনের কাজ চলছে। খুব শীঘ্রই অ্যাপটি স্বাভাবিকভাবে চালু হবে। সাথে থাকার জন্য ধন্যবাদ।';

    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage(AssetImagePaths.seamlessImg),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.build_circle_outlined,
                  size: 72,
                  color: LightThemeColors.primaryColor,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 22,
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    displayMessage,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // SizedBox(
                //   height: 400,
                //   width: 300,
                //   child: Lottie.asset(AppImages.maintenanceModeJson),
                // ),
                const SizedBox(height: 30.00),
                Row(
                  children: [
                    Expanded(
                      child: CustomActionButton(
                        text: "Refresh",
                        onPressed: () {
                          Get.offAllNamed(Routes.SPLASH);
                        },
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: CustomActionButton(
                        btnBackgroundColor: Colors.red,
                        text: "Exit",
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
