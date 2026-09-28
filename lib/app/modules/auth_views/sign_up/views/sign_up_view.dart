import 'package:lokkha/config/extensions/common_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../../config/constants/app_images.dart';
import '../../../../../styles/text_style.dart';
import '../../../../components/custom_action_button.dart';
import '../../../../components/custom_snackbar.dart';
import '../../../../components/custom_text_form_field.dart';
import '../controllers/sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder(
          init: SignUpController(),
          builder: (x) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 5.00.h,
                  children: [
                    50.height,
                    Image.asset(AssetImagePaths.appIcon, scale: 2.0),
                    Text(
                      "এক টাকা দিয়ে লক্ষ্যে পৌঁছান",
                      style: AppTextStyles.heading4,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "কোনো রেজিস্ট্রেশন এর প্রয়োজন নেই সরাসরি লগইন করুন",
                      style: AppTextStyles.body1.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    90.h.height,
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
                      autoFocus: true,
                      controller: controller.phoneController,
                      prefixIcon: const Icon(Icons.phone),
                      hintText: "আপনার ১১ সংখ্যার ফোন নম্বর লিখুন",
                      hintStyle: AppTextStyles.body2,
                      keyboardType: TextInputType.number,
                    ),
                    1.0.h.height,
                    CustomActionButton(
                      text: "এগিয়ে যান",
                      isLoading: controller.isLoading,
                      onPressed: () {
                        debugPrint(controller.phoneController.text);
                        if (controller.phoneController.text.trim().isEmpty) {
                          CustomSnackBar.showCustomErrorSnackBar(
                            title: 'Invalid credentials.',
                            message: "Please provide your phone number",
                          );
                        } else {
                          controller.checkPhoneNumber();
                        }
                      },
                    ),
                  ],
                ).paddingAll(8.00.r),
              ),
            );
          }),
    );
  }
}
