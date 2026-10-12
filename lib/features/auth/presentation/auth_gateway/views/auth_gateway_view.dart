import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/shared/widgets/custom_decision_button.dart';

class AuthGatewayView extends ConsumerWidget {
  const AuthGatewayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              100.h.height,
              Image.asset(AssetImagePaths.appIcon, scale: 2.0),
              SizedBox(height: 8.h),
              Text(
                "সঠিক পথে, স্বল্প সময়ে",
                style: AppTextStyles.heading4,
              ),
              SizedBox(height: 8.h),
              Text(
                "কোনো রেজিস্ট্রেশন এর প্রয়োজন নেই সরাসরি লগইন করুন",
                style: AppTextStyles.body1,
              ),
              50.h.height,
              DecisionButton(
                text: "Sign in with Phone",
                leadingWidget: const Icon(Icons.phone, size: 20),
                onPressed: () {
                  context.push(Routes.signUp);
                },
              ),
              40.h.height,
              RichText(
                text: TextSpan(
                  children: [
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BaseWebView(
                                title: "শর্তাবলী ও নীতিমালা",
                                url: AppConstants.termsPolicy,
                              ),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Version ${appVersion.value.isNotEmpty ? appVersion.value : ''}",
                style: AppTextStyles.custom(fontSize: 11.0.sp),
              ),
            ],
          ).paddingAll(8.00.r),
        ),
      ),
    );
  }
}
