import 'package:lokkha/shared/widgets/custom_text_form_field.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/theme/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/routes/routes.dart';
import '../controllers/forget_password_controller.dart';

class ForgetPasswordView extends GetView<ForgetPasswordController> {
  const ForgetPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.0.h,
          children: [
            20.0.h.height,
            Center(
              child: Text(
                'পাসওয়ার্ড ভুলে গেছেন?',
                style: AppTextStyles.heading1
                    .copyWith(color: LightThemeColors.primaryColor),
              ),
            ),
            const Text(
              "আপনার ফোন নম্বর এ ৬ ডিজিটের OTP পাঠানো ভেরিফাই করুন",
              textAlign: TextAlign.center,
            ),
            const CustomTextFormField(
              controller: null,
              prefixIcon: Icon(Icons.phone),
              hintText: "আপনার ১১ সংখ্যার ফোন নম্বর লিখুন",
            ),
            CustomActionButton(
              text: "Verify",
              onPressed: () {
                Get.toNamed(Routes.HOME);
              },
            ),
          ],
        ).paddingAll(8.00.r),
      ),
    );
  }
}
