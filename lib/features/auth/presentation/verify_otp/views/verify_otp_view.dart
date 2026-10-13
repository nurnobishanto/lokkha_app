import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:pinput/pinput.dart';
import '../riverpod/verify_otp_notifier.dart';

class VerifyOtpView extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String type;

  const VerifyOtpView({
    super.key,
    this.phoneNumber = '',
    this.type = 'Registration',
  });

  @override
  ConsumerState<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends ConsumerState<VerifyOtpView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.phoneNumber.isNotEmpty) {
        ref
            .read(verifyOtpNotifierProvider.notifier)
            .sendOtp(widget.phoneNumber, widget.type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final verifyOtpState = ref.watch(verifyOtpNotifierProvider);

    final defaultPinTheme = PinTheme(
      height: 50.0,
      width: 50.0,
      textStyle: TextStyle(
        fontSize: 20.0,
        color: context.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.primaryColor, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: Container(
        decoration: BoxDecoration(
          color: context.scaffoldColor,
          image: context.isDark
              ? null
              : DecorationImage(
                  image: AssetImage(AssetImagePaths.seamlessImg),
                  fit: BoxFit.cover,
                ),
        ),
        child: Column(
          children: [
            120.h.height,
            Image.asset(AssetImagePaths.otpImg, scale: 1.9),
            Center(
              child: Text(
                "আপনার এই ${widget.phoneNumber} ফোন নম্বর এ ৬ ডিজিটের OTP পাঠানো হয়েছে ভেরিফাই করুন",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            10.h.height,
            Pinput(
              autofocus: true,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: (pin) {
                ref.read(verifyOtpNotifierProvider.notifier).setOtp(pin);
              },
              onChanged: (pin) {
                ref.read(verifyOtpNotifierProvider.notifier).setOtp(pin);
              },
            ),
            10.h.height,
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "OTP পাচ্ছো না? ",
                  style: TextStyle(
                    color: context.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: "Resend OTP",
                      style: AppTextStyles.custom(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ref
                              .read(verifyOtpNotifierProvider.notifier)
                              .sendOtp(widget.phoneNumber, widget.type);
                        },
                    ),
                  ],
                ),
              ),
            ),
            50.h.height,
            CustomActionButton(
              text: "Verify",
              isLoading: verifyOtpState.isLoading,
              onPressed: () {
                if (widget.type == 'Registration') {
                  ref
                      .read(verifyOtpNotifierProvider.notifier)
                      .register(widget.phoneNumber, context);
                } else {
                  ref
                      .read(verifyOtpNotifierProvider.notifier)
                      .loginWithOtp(widget.phoneNumber, context);
                }
              },
            ),
          ],
        ).paddingAll(8.00.r),
      ),
    );
  }
}
