import 'dart:io';

import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/shared/widgets/custom_drop_down_button.dart';
import 'package:lokkha/shared/widgets/custom_text_form_field.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/theme/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import '../controllers/profile_update_controller.dart';

class ProfileUpdateView extends GetView<ProfileUpdateController> {
  const ProfileUpdateView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'প্রোফাইল আপডেট করুন'),
      body: Obx(() {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.h.height,
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        controller.croppedImage.value != null
                            ? CircleAvatar(
                                radius: 64.0,
                                backgroundColor: LightThemeColors.primaryColor,
                                child: CircleAvatar(
                                  radius: 62.0,
                                  backgroundImage: FileImage(
                                    File(controller.croppedImage.value!.path),
                                  ),
                                ),
                              )
                            : buildAvatar(myUser, radius: 64),
                        Positioned(
                          bottom: 0.8,
                          right: 0.5,
                          child: InkWell(
                            onTap: () {
                              controller.pickImage();
                            },
                            child: CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  15.h.height,
                  Text(
                    'নাম',
                    style: AppTextStyles.body1,
                  ),
                  2.h.height,
                  CustomTextFormField(
                    controller: controller.nameController,
                    hintText: 'আপনার নাম লিখুন',
                  ),
                  10.h.height,
                  Text(
                    'ইমেইল',
                    style: AppTextStyles.body1,
                  ),
                  2.h.height,
                  CustomTextFormField(
                    controller: controller.emailController,
                    hintText: 'আপনার ইমেইল ঠিকানা লিখুন',
                  ),
                  10.h.height,
                  Text("জন্ম তারিখ", style: AppTextStyles.body1),
                  2.h.height,
                  CustomTextFormField(
                    hintText: controller.dob.value.trim().isEmpty
                        ? Get.find<NavbarController>()
                            .profileDataModel
                            .value!
                            .user!
                            .dateOfBirth
                            .toString()
                            .split(" ")
                            .first
                        : controller.dob.value,
                    readOnly: true,
                    onTap: () => controller.selectDate(context),
                  ),
                  10.h.height,
                  Text(
                    'লিঙ্গ',
                    style: AppTextStyles.body1,
                  ),
                  2.h.height,
                  CustomDropdownButton(
                    items: const ["পুরুষ", 'মহিলা', 'অন্যান্য'],
                    dropdownValue: controller.gender.value.isEmpty
                        ? Get.find<NavbarController>()
                            .profileDataModel
                            .value!
                            .user!
                            .gender
                            .toString()
                        : controller.gender.value,
                    onChanged: (v) {
                      controller.gender.value = v!;
                    },
                  ),
                  10.h.height,
                  Text(
                    'পেশা',
                    style: AppTextStyles.body1,
                  ),
                  2.h.height,
                  CustomTextFormField(
                    controller: controller.occupationController,
                    hintText: 'পেশা প্রদর্শিত হবে',
                  ),
                  10.h.height,
                  Text(
                    'প্রতিষ্ঠান',
                    style: AppTextStyles.body1,
                  ),
                  2.h.height,
                  CustomTextFormField(
                    controller: controller.organizationController,
                    hintText: 'প্রতিষ্ঠানের নাম প্রদর্শিত হবে',
                  ),
                  20.h.height,
                  Text(
                    'পাসওয়ার্ড',
                    style: AppTextStyles.heading6,
                  ),
                  10.h.height,
                  Text(
                    'পরিবর্তন করতে না চাইলে এই অংশ ফাঁকা রাখুন',
                    style: AppTextStyles.body1,
                  ),
                  5.h.height,
                  Text(
                    'নতুন পাসওয়ার্ড',
                    style: AppTextStyles.body1,
                  ),
                  3.h.height,
                  CustomTextFormField(
                    controller: controller.pwdController,
                    hintText: 'নতুন পাসওয়ার্ড লিখুন',
                    obscureText: true,
                  ),
                  5.h.height,
                  Text(
                    'পাসওয়ার্ড নিশ্চিত করুন',
                    style: AppTextStyles.body1,
                  ),
                  3.h.height,
                  CustomTextFormField(
                    controller: controller.confirmPwdController,
                    hintText: 'পুনরায় পাসওয়ার্ড লিখুন',
                    obscureText: true,
                  ),
                  20.h.height,
                  CustomActionButton(
                    text: "আপডেট করুন",
                    onPressed: () {
                      controller.updateProfileInfo(context);
                    },
                  ),
                  30.h.height,
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

