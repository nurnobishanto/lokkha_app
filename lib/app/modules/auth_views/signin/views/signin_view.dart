import 'package:lokkha/app/components/custom_action_button.dart';
import 'package:lokkha/app/components/custom_text_form_field.dart';
import 'package:lokkha/config/constants/app_images.dart';
import 'package:lokkha/config/extensions/common_extension.dart';
import 'package:lokkha/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/signin_controller.dart';

class SignInView extends GetView<SignInController> {
  final String phoneNumber;
  final String type;

  SignInView({super.key})
      : phoneNumber = Get.arguments['phoneNumber'],
        type = Get.arguments['type'];

  @override
  Widget build(BuildContext context) {
    debugPrint('MY PHONE $phoneNumber');
    return Scaffold(
        body: GetBuilder(
            init: SignInController(),
            builder: (x) {
              return SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    spacing: 5.00.h,
                    children: [
                      100.height,
                      Image.asset(AssetImagePaths.appIcon, scale: 1.5),
                      Text(
                        "এক টাকা দিয়ে লক্ষ্যে পৌঁছান",
                        style: AppTextStyles.heading4
                            .copyWith(color: context.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "কোনো রেজিস্ট্রেশন এর প্রয়োজন নেই সরাসরি লগইন করুন",
                        style: AppTextStyles.custom(
                          color: context.primaryColor,
                        ),
                      ),
                      70.h.height,
                      Text(
                        "আপনার ফোন নম্বর দিয়ে লগইন করুন",
                        style: AppTextStyles.custom(
                          fontSize: 17.00.sp,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      2.0.h.height,
                      CustomTextFormField(
                        readOnly: true,
                        prefixIcon: const Icon(Icons.phone),
                        hintText: phoneNumber,
                        hintStyle: AppTextStyles.heading6.copyWith(color: context.textPrimary),
                      ),
                      1.0.h.height,
                      CustomTextFormField(
                        autoFocus: true,
                        controller: controller.passwordController,
                        prefixIcon: const Icon(Icons.lock),
                        hintText: "আপনার পাসওয়ার্ড লিখুন",
                        obscureText: true,
                        hintStyle: AppTextStyles.custom(
                            fontSize: 12.00.sp,
                            color: context.textMuted),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.VERIFY_OTP, arguments: {
                              'phoneNumber': phoneNumber,
                              'type': 'Login',
                            });
                          },
                          child: Text(
                            'পাসওয়ার্ড মনে নেই? OTP দিয়ে লগইন করুন!',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.custom(
                                fontSize: 11.5.sp,
                                color: context.primaryColor),
                          ),
                        ),
                      ),
                      1.0.h.height,
                      CustomActionButton(
                        text: "এগিয়ে যান",
                        isLoading: controller.isLoading,
                        onPressed: () {
                          controller.login(
                            phoneNumber,
                            type,
                            controller.passwordController.text,
                          );
                        },
                      ),
                    ],
                  ).paddingAll(8.00.r),
                ),
              );
            }));
  }
}
