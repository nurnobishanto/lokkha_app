import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/theme/theme.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/shared/widgets/custom_text_form_field.dart';
import '../controllers/sign_up_notifier.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8.0.r),
          child: Column(
            children: [
              50.height,
              Image.asset(AssetImagePaths.appIcon, scale: 2.0),
              SizedBox(height: 5.h),
              Text(
                "এক টাকা দিয়ে লক্ষ্যে পৌঁছান",
                style: AppTextStyles.heading4,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),
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
                controller: _phoneController,
                prefixIcon: const Icon(Icons.phone),
                hintText: "আপনার ১১ সংখ্যার ফোন নম্বর লিখুন",
                hintStyle: AppTextStyles.body2,
                keyboardType: TextInputType.number,
              ),
              1.0.h.height,
              CustomActionButton(
                text: "এগিয়ে যান",
                isLoading: signUpState.isLoading,
                onPressed: () {
                  final text = _phoneController.text.trim();
                  if (text.isEmpty) {
                    CustomSnackBar.showCustomErrorSnackBar(
                      title: 'Invalid credentials.',
                      message: "Please provide your phone number",
                    );
                  } else {
                    ref
                        .read(signUpNotifierProvider.notifier)
                        .checkPhoneNumber(text, context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
