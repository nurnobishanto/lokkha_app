import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/app_route_paths.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/theme/theme.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_text_form_field.dart';

class ForgetPasswordView extends ConsumerWidget {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.0.h.height,
            Center(
              child: Text(
                'পাসওয়ার্ড ভুলে গেছেন?',
                style: AppTextStyles.heading1
                    .copyWith(color: LightThemeColors.primaryColor),
              ),
            ),
            SizedBox(height: 10.h),
            const Text(
              "আপনার ফোন নম্বর এ ৬ ডিজিটের OTP পাঠানো ভেরিফাই করুন",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            const CustomTextFormField(
              controller: null,
              prefixIcon: Icon(Icons.phone),
              hintText: "আপনার ১১ সংখ্যার ফোন নম্বর লিখুন",
            ),
            SizedBox(height: 10.h),
            CustomActionButton(
              text: "Verify",
              onPressed: () {
                try {
                  context.go(AppRoutePaths.home);
                } catch (_) {
                  Get.toNamed(Routes.HOME);
                }
              },
            ),
          ],
        ).paddingAll(8.00.r),
      ),
    );
  }
}
