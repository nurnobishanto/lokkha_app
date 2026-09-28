import 'package:flutter/material.dart';
import 'package:lokkha/app/components/custom_decision_button.dart';
import 'package:lokkha/app/views/widgets/base_webview.dart';
import 'package:lokkha/app/helper/global.dart';
import 'package:lokkha/config/constants/app_images.dart';
import 'package:lokkha/config/extensions/common_extension.dart';
import 'package:lokkha/styles/text_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/utils/constants.dart';

import '../../../../routes/app_pages.dart';
import '../controllers/auth_gateway_controller.dart';



class AuthGatewayView extends GetView<AuthGatewayController> {
  const AuthGatewayView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 8.0.h,
            children: [
              100.h.height,
              Image.asset(AssetImagePaths.appIcon, scale: 2.0),
              Text(
                "সঠিক পথে, স্বল্প সময়ে",
                style: AppTextStyles.heading4,
              ),
              Text(
                "কোনো রেজিস্ট্রেশন এর প্রয়োজন নেই সরাসরি লগইন করুন",
                style: AppTextStyles.body1,
              ),
              50.h.height,

              DecisionButton(
                text: "Sign in with Phone",
                leadingWidget: const Icon(Icons.phone, size: 20),
                onPressed: () {
                  Get.toNamed(Routes.SIGN_UP);
                },
              ),

              40.h.height, // Added instead of Spacer()

              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'লগ ইন করে, আপনি আমাদের সাথে সম্মত হন।',
                    style: AppTextStyles.custom(fontSize: 11.0.sp).copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: ' শর্তাবলী ও নীতিমালা',
                    style: AppTextStyles.custom(
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w700,
                      color: context.primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(
                          BaseWebView(
                            title: "শর্তাবলী ও নীতিমালা",
                            url: AppConstants.termsPolicy,
                          ),
                        );
                      },
                  ),
                ]),
              ),
              Obx(
                () => Text(
                  "Version ${appVersion.value.isNotEmpty ? appVersion.value : ''}",
                  style: AppTextStyles.custom(fontSize: 11.0.sp),
                ),
              ),
            ],
          ).paddingAll(8.00.r),
        ),
      ),
    );
  }
}
