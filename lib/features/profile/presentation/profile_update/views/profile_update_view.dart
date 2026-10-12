import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/shared/widgets/custom_drop_down_button.dart';
import 'package:lokkha/shared/widgets/custom_text_form_field.dart';
import '../controllers/profile_update_notifier.dart';

class ProfileUpdateView extends ConsumerStatefulWidget {
  const ProfileUpdateView({super.key});

  @override
  ConsumerState<ProfileUpdateView> createState() => _ProfileUpdateViewState();
}

class _ProfileUpdateViewState extends ConsumerState<ProfileUpdateView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _organizationController;
  late final TextEditingController _occupationController;
  late final TextEditingController _currentPwdController;
  late final TextEditingController _pwdController;
  late final TextEditingController _confirmPwdController;

  @override
  void initState() {
    super.initState();
    final user = myUser;
    _nameController = TextEditingController(text: user.name ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _organizationController =
        TextEditingController(text: user.organization ?? '');
    _occupationController = TextEditingController(text: user.occupation ?? '');
    _currentPwdController = TextEditingController();
    _pwdController = TextEditingController();
    _confirmPwdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    _occupationController.dispose();
    _currentPwdController.dispose();
    _pwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final notifier = ref.read(profileUpdateNotifierProvider.notifier);
    final success = await notifier.updateProfileInfo(
      context: context,
      name: _nameController.text,
      email: _emailController.text,
      organization: _organizationController.text,
      occupation: _occupationController.text,
      currentPwd: _currentPwdController.text,
      newPwd: _pwdController.text,
      confirmPwd: _confirmPwdController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileUpdateNotifierProvider);
    final notifier = ref.read(profileUpdateNotifierProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'প্রোফাইল আপডেট করুন'),
      body: SafeArea(
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
                      state.croppedImage != null
                          ? CircleAvatar(
                              radius: 64.0,
                              backgroundColor: LightThemeColors.primaryColor,
                              child: CircleAvatar(
                                radius: 62.0,
                                backgroundImage: FileImage(
                                  File(state.croppedImage!.path),
                                ),
                              ),
                            )
                          : buildAvatar(myUser, radius: 64),
                      Positioned(
                        bottom: 0.8,
                        right: 0.5,
                        child: InkWell(
                          onTap: notifier.pickImage,
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
                  controller: _nameController,
                  hintText: 'আপনার নাম লিখুন',
                ),
                10.h.height,
                Text(
                  'ইমেইল',
                  style: AppTextStyles.body1,
                ),
                2.h.height,
                CustomTextFormField(
                  controller: _emailController,
                  hintText: 'আপনার ইমেইল ঠিকানা লিখুন',
                ),
                10.h.height,
                Text("জন্ম তারিখ", style: AppTextStyles.body1),
                2.h.height,
                CustomTextFormField(
                  hintText: state.dob.trim().isEmpty
                      ? (myUser.dateOfBirth?.split(" ").first ?? '')
                      : state.dob,
                  readOnly: true,
                  onTap: () => notifier.selectDate(context),
                ),
                10.h.height,
                Text(
                  'লিঙ্গ',
                  style: AppTextStyles.body1,
                ),
                2.h.height,
                CustomDropdownButton(
                  items: const ["পুরুষ", 'মহিলা', 'অন্যান্য'],
                  dropdownValue: state.gender.isEmpty
                      ? (myUser.gender ?? '')
                      : state.gender,
                  onChanged: (v) {
                    if (v != null) {
                      notifier.setGender(v);
                    }
                  },
                ),
                10.h.height,
                Text(
                  'পেশা',
                  style: AppTextStyles.body1,
                ),
                2.h.height,
                CustomTextFormField(
                  controller: _occupationController,
                  hintText: 'পেশা প্রদর্শিত হবে',
                ),
                10.h.height,
                Text(
                  'প্রতিষ্ঠান',
                  style: AppTextStyles.body1,
                ),
                2.h.height,
                CustomTextFormField(
                  controller: _organizationController,
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
                  'বর্তমান পাসওয়ার্ড',
                  style: AppTextStyles.body1,
                ),
                3.h.height,
                CustomTextFormField(
                  controller: _currentPwdController,
                  hintText: 'আপনার বর্তমান পাসওয়ার্ড লিখুন',
                  obscureText: true,
                ),
                5.h.height,
                Text(
                  'নতুন পাসওয়ার্ড',
                  style: AppTextStyles.body1,
                ),
                3.h.height,
                CustomTextFormField(
                  controller: _pwdController,
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
                  controller: _confirmPwdController,
                  hintText: 'পুনরায় পাসওয়ার্ড লিখুন',
                  obscureText: true,
                ),
                20.h.height,
                CustomActionButton(
                  text: "আপডেট করুন",
                  isLoading: state.isLoading,
                  onPressed: _handleUpdate,
                ),
                30.h.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
