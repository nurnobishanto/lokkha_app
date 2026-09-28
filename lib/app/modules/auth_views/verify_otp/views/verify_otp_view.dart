import 'package:lokkha/app/components/custom_action_button.dart';
import 'package:lokkha/app/components/custom_snackbar.dart';
import 'package:lokkha/app/modules/auth_views/signin/controllers/signin_controller.dart';
import 'package:lokkha/config/constants/app_images.dart';
import 'package:lokkha/config/extensions/common_extension.dart';
import 'package:lokkha/styles/text_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../controllers/verify_otp_controller.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  final String phoneNumber;
  final String type;

  // Constructor accepting both type and phoneNumber as arguments
  VerifyOtpView({super.key})
      : phoneNumber =
            Get.arguments['phoneNumber'], // Get the phone number from arguments
        type = Get.arguments['type']; // Get the type from arguments

  @override
  Widget build(BuildContext context) {
    debugPrint('MY PHONE $phoneNumber>> ${phoneNumber.runtimeType}');
    debugPrint('OTP TYPE $type');

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
      body: GetBuilder<VerifyOtpController>(
          init: VerifyOtpController(),
          builder: (x) {
            return Container(
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
                      "আপনার এই $phoneNumber ফোন নম্বর এ ৬ ডিজিটের OTP পাঠানো ভেরিফাই করুন",
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
                      debugPrint("Otp pin $pin");
                      if (controller.otp != pin) {
                        controller.otp = pin;
                      }
                    },
                    onChanged: (pin) {
                      debugPrint('Pin Changed: $pin');
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
                                controller.sendOtp(phoneNumber, type);
                                debugPrint("Resend OTP tapped!");
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  50.h.height,
                  CustomActionButton(
                    text: "Verify",
                    onPressed: () {
                      if (type == 'Registration') {
                        debugPrint("Tapped Registration");
                        controller.register(phoneNumber);
                      } else {
                        if (controller.otp?.length == 6) {
                          Get.find<SignInController>().login(
                              phoneNumber, 'otp', controller.otp.toString());
                        } else {
                          CustomSnackBar.showCustomErrorSnackBar(
                              title: 'Please Fill the pin',
                              message: 'OTP must be 6 digits.');
                        }
                      }
                    },
                  ),
                ],
              ).paddingAll(8.00.r),
            );
          }),
    );
  }
}
