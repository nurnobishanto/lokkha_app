import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/app_route_paths.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/theme/theme.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_text_form_field.dart';
import '../controllers/sign_in_notifier.dart';

class SignInView extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String type;

  SignInView({
    super.key,
    String? phoneNumber,
    String? type,
  })  : phoneNumber = phoneNumber ??
            Get.arguments?['phoneNumber']?.toString() ??
            '',
        type = type ?? Get.arguments?['type']?.toString() ?? 'password';

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInNotifierProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              100.height,
              Image.asset(AssetImagePaths.appIcon, scale: 1.5),
              SizedBox(height: 5.h),
              Text(
                "এক টাকা দিয়ে লক্ষ্যে পৌঁছান",
                style: AppTextStyles.heading4
                    .copyWith(color: context.textPrimary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),
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
                hintText: widget.phoneNumber,
                hintStyle:
                    AppTextStyles.heading6.copyWith(color: context.textPrimary),
              ),
              1.0.h.height,
              CustomTextFormField(
                autoFocus: true,
                controller: _passwordController,
                prefixIcon: const Icon(Icons.lock),
                hintText: "আপনার পাসওয়ার্ড লিখুন",
                obscureText: true,
                hintStyle: AppTextStyles.custom(
                    fontSize: 12.00.sp, color: context.textMuted),
              ),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    try {
                      context.push(
                        AppRoutePaths.verifyOtp,
                        extra: {
                          'phoneNumber': widget.phoneNumber,
                          'type': 'Login',
                        },
                      );
                    } catch (_) {
                      Get.toNamed(Routes.VERIFY_OTP, arguments: {
                        'phoneNumber': widget.phoneNumber,
                        'type': 'Login',
                      });
                    }
                  },
                  child: Text(
                    'পাসওয়ার্ড মনে নেই? OTP দিয়ে লগইন করুন!',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.custom(
                        fontSize: 11.5.sp, color: context.primaryColor),
                  ),
                ),
              ),
              1.0.h.height,
              CustomActionButton(
                text: "এগিয়ে যান",
                isLoading: signInState.isLoading,
                onPressed: () {
                  ref.read(signInNotifierProvider.notifier).login(
                        phone: widget.phoneNumber,
                        type: widget.type,
                        password: _passwordController.text,
                        context: context,
                      );
                },
              ),
            ],
          ).paddingAll(8.00.r),
        ),
      ),
    );
  }
}
