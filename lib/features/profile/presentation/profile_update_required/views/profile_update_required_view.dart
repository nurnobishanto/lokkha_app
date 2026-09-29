import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_text_form_field.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/theme/text_style.dart';
import '../controllers/profile_update_required_controller.dart';

class ProfileUpdateRequiredView
    extends GetView<ProfileUpdateRequiredController> {
  final String phoneNumber;
  ProfileUpdateRequiredView({super.key})
      : phoneNumber = Get.arguments['phoneNumber'];

  @override
  Widget build(BuildContext context) {
    debugPrint("Phone Number: $phoneNumber");
    return Scaffold(
      appBar: AppBar(title: const Text('চলুন শুরু করি!')),
      body: GetBuilder<ProfileUpdateRequiredController>(
          init: ProfileUpdateRequiredController(),
          builder: (_) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  5.0.h.height,
                  Text("নাম", style: AppTextStyles.heading5),
                  2.0.h.height,
                  CustomTextFormField(
                    controller: controller.nameController,
                    hintText: 'আপনার পূর্ণ নাম',
                    hintStyle: AppTextStyles.custom(
                        fontSize: 12.5, color: LightThemeColors.hintTextColor),
                  ),
                  _conditionalPhoneInput(phoneNumber, controller),
                  10.0.h.height,
                  Text("জন্ম তারিখ", style: AppTextStyles.heading5),
                  2.0.h.height,
                  CustomTextFormField(
                    hintText: 'আপনার জন্ম তারিখ',
                    readOnly: true,
                    hintStyle: AppTextStyles.custom(
                        fontSize: 12.5, color: LightThemeColors.hintTextColor),
                    controller: controller.dobController,
                    onTap: () {
                      controller.selectDate(context);
                    },
                  ),
                  10.0.h.height,
                  Text("লিঙ্গ", style: AppTextStyles.heading6),
                  Wrap(
                    spacing: 20,
                    children: ["male", "female", "other"].map((gender) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: gender,
                            groupValue: controller.gender,
                            visualDensity: const VisualDensity(
                                horizontal: -4, vertical: -2),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              controller.gender = val!;
                              controller.update();
                            },
                          ),
                          Text(
                            gender == "male"
                                ? "পুরুষ"
                                : gender == "female"
                                    ? "মহিলা"
                                    : "অন্যান্য",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  10.0.h.height,
                  Text("পেশা", style: AppTextStyles.heading5),
                  _occupationRadioTile("স্টুডেন্ট", "Student", controller),
                  _occupationRadioTile("চাকরিজীবী", "Job Holder", controller),
                  _occupationRadioTile(
                      "চাকরি খুঁজছেন", "Job Seeker", controller),
                  10.0.h.height,
                  Text("পাসওয়ার্ড", style: AppTextStyles.heading5),
                  2.0.h.height,
                  SizedBox(
                    height: 45,
                    child: CustomTextFormField(
                      controller: controller.pwdController,
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "একটি পাসওয়ার্ড নির্ধারণ করুন",
                      obscureText: true,
                      hintStyle: AppTextStyles.custom(
                          fontSize: 12.00.sp,
                          color: LightThemeColors.hintTextColor),
                    ),
                  ),
                  10.0.h.height,
                  Text("পাসওয়ার্ড নিশ্চিত করুন",
                      style: AppTextStyles.heading5),
                  2.0.h.height,
                  SizedBox(
                    height: 45,
                    child: CustomTextFormField(
                      controller: controller.confirmPwdController,
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "পাসওয়ার্ডটি আবার লিখুন",
                      obscureText: true,
                      hintStyle: AppTextStyles.custom(
                          fontSize: 12.00.sp,
                          color: LightThemeColors.hintTextColor),
                    ),
                  ),
                  25.h.height,
                  CustomActionButton(
                    text: "আপডেট করুন",
                    onPressed: () {
                      //controller.submit();
                      controller.updateProfileRequired();
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}

RadioListTile _occupationRadioTile(
    String title, String value, ProfileUpdateRequiredController controller) {
  return RadioListTile(
    contentPadding: EdgeInsets.zero,
    dense: true,
    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    title: Text(title),
    value: value,
    groupValue: controller.occupation,
    onChanged: (val) {
      controller.occupation = val!;
      debugPrint("Select occupation: $val");
      controller.update();
    },
  );
}

Widget _conditionalPhoneInput(
    String phoneNumber, ProfileUpdateRequiredController controller) {
  if (phoneNumber.isNotEmpty) return const SizedBox();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      10.0.h.height,
      Text("ফোন নম্বর", style: AppTextStyles.heading5),
      2.0.h.height,
      CustomTextFormField(
        controller: controller.phoneController,
        hintText: 'আপনার ফোন নম্বর',
        hintStyle: AppTextStyles.custom(
          fontSize: 12.5,
          color: LightThemeColors.hintTextColor,
        ),
      ),
    ],
  );
}
