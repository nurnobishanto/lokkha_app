import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_text_form_field.dart';
import '../riverpod/profile_update_required_notifier.dart';

class ProfileUpdateRequiredView extends ConsumerStatefulWidget {
  final String? phoneNumber;

  const ProfileUpdateRequiredView({
    super.key,
    this.phoneNumber,
  });

  @override
  ConsumerState<ProfileUpdateRequiredView> createState() =>
      _ProfileUpdateRequiredViewState();
}

class _ProfileUpdateRequiredViewState
    extends ConsumerState<ProfileUpdateRequiredView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _pwdController;
  late final TextEditingController _confirmPwdController;
  late final TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController(text: widget.phoneNumber ?? '');
    _pwdController = TextEditingController();
    _confirmPwdController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pwdController.dispose();
    _confirmPwdController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = picked.toIso8601String().split("T").first;
    }
  }

  Future<void> _handleUpdate() async {
    final notifier = ref.read(profileUpdateRequiredNotifierProvider.notifier);
    final success = await notifier.updateProfileRequired(
      name: _nameController.text,
      phone: _phoneController.text,
      dob: _dobController.text,
      pwd: _pwdController.text,
      confirmPwd: _confirmPwdController.text,
    );

    if (success && mounted) {
      context.go(Routes.navbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileUpdateRequiredNotifierProvider);
    final notifier = ref.read(profileUpdateRequiredNotifierProvider.notifier);
    final phone = widget.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('চলুন শুরু করি!')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            5.0.h.height,
            Text("নাম", style: AppTextStyles.heading5),
            2.0.h.height,
            CustomTextFormField(
              controller: _nameController,
              hintText: 'আপনার পূর্ণ নাম',
              hintStyle: AppTextStyles.custom(
                fontSize: 12.5,
                color: LightThemeColors.hintTextColor,
              ),
            ),
            if (phone.isEmpty) ...[
              10.0.h.height,
              Text("ফোন নম্বর", style: AppTextStyles.heading5),
              2.0.h.height,
              CustomTextFormField(
                controller: _phoneController,
                hintText: 'আপনার ফোন নম্বর',
                hintStyle: AppTextStyles.custom(
                  fontSize: 12.5,
                  color: LightThemeColors.hintTextColor,
                ),
              ),
            ],
            10.0.h.height,
            Text("জন্ম তারিখ", style: AppTextStyles.heading5),
            2.0.h.height,
            CustomTextFormField(
              hintText: 'আপনার জন্ম তারিখ',
              readOnly: true,
              hintStyle: AppTextStyles.custom(
                fontSize: 12.5,
                color: LightThemeColors.hintTextColor,
              ),
              controller: _dobController,
              onTap: _selectDate,
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
                      groupValue: state.gender,
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -2,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) {
                        if (val != null) {
                          notifier.setGender(val);
                        }
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
            _buildOccupationTile("স্টুডেন্ট", "Student", state.occupation, notifier),
            _buildOccupationTile("চাকরিজীবী", "Job Holder", state.occupation, notifier),
            _buildOccupationTile("চাকরি খুঁজছেন", "Job Seeker", state.occupation, notifier),
            10.0.h.height,
            Text("পাসওয়ার্ড", style: AppTextStyles.heading5),
            2.0.h.height,
            SizedBox(
              height: 45,
              child: CustomTextFormField(
                controller: _pwdController,
                prefixIcon: const Icon(Icons.lock),
                hintText: "একটি পাসওয়ার্ড নির্ধারণ করুন",
                obscureText: true,
                hintStyle: AppTextStyles.custom(
                  fontSize: 12.sp,
                  color: LightThemeColors.hintTextColor,
                ),
              ),
            ),
            10.0.h.height,
            Text("পাসওয়ার্ড নিশ্চিত করুন", style: AppTextStyles.heading5),
            2.0.h.height,
            SizedBox(
              height: 45,
              child: CustomTextFormField(
                controller: _confirmPwdController,
                prefixIcon: const Icon(Icons.lock),
                hintText: "পাসওয়ার্ডটি আবার লিখুন",
                obscureText: true,
                hintStyle: AppTextStyles.custom(
                  fontSize: 12.sp,
                  color: LightThemeColors.hintTextColor,
                ),
              ),
            ),
            25.h.height,
            CustomActionButton(
              text: "আপডেট করুন",
              isLoading: state.isLoading,
              onPressed: _handleUpdate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupationTile(
    String title,
    String value,
    String selectedValue,
    ProfileUpdateRequiredNotifier notifier,
  ) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      title: Text(title),
      value: value,
      groupValue: selectedValue,
      onChanged: (val) {
        if (val != null) {
          notifier.setOccupation(val);
        }
      },
    );
  }
}
