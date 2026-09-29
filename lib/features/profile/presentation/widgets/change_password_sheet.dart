import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChangePasswordSheet(),
    );
  }

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ChangePasswordUseCase _changePasswordUseCase =
      ChangePasswordUseCase(repository: ProfileRepository());

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "পাসওয়ার্ড আবশ্যক",
        message: "আপনার বর্তমান পাসওয়ার্ড প্রদান করুন।",
      );
      return;
    }

    if (newPassword.isEmpty || newPassword.length < 6) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "নতুন পাসওয়ার্ড ত্রুটি",
        message: "নতুন পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।",
      );
      return;
    }

    if (newPassword != confirmPassword) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "পাসওয়ার্ড মিলছে না",
        message: "নতুন পাসওয়ার্ড এবং নিশ্চিতকরণ পাসওয়ার্ড এক হতে হবে।",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _changePasswordUseCase(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final isSuccess = res['success'] == true || res['status'] == true;
      if (isSuccess) {
        if (mounted) {
          Navigator.pop(context);
        }
        CustomSnackBar.showCustomToast(
          message: res['message']?.toString() ?? "পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে।",
        );
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: "ব্যর্থ",
          message: res['message']?.toString() ?? "পাসওয়ার্ড পরিবর্তন সম্পন্ন করা যায়নি।",
        );
      }
    } catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "ত্রুটি",
        message: "সার্ভারে সংযোগ স্থাপন করা সম্ভব হয়নি। অনুগ্রহ করে আবার চেষ্টা করুন।",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 14.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        color: context.primaryColor,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "পাসওয়ার্ড পরিবর্তন করুন",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.textMuted),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              "আপনার অ্যাকাউন্টের নিরাপত্তা নিশ্চিত করতে বর্তমান পাসওয়ার্ড নিশ্চিত করে নতুন পাসওয়ার্ড দিন।",
              style: TextStyle(fontSize: 12.sp, color: context.textMuted),
            ),
            SizedBox(height: 18.h),

            // Current Password
            _buildPasswordField(
              context: context,
              controller: _currentPasswordController,
              label: "বর্তমান পাসওয়ার্ড",
              hintText: "আপনার বর্তমান পাসওয়ার্ড লিখুন",
              obscureText: _obscureCurrent,
              onToggleVisibility: () {
                setState(() => _obscureCurrent = !_obscureCurrent);
              },
            ),
            SizedBox(height: 14.h),

            // New Password
            _buildPasswordField(
              context: context,
              controller: _newPasswordController,
              label: "নতুন পাসওয়ার্ড",
              hintText: "কমপক্ষে ৬ অক্ষরের নতুন পাসওয়ার্ড",
              obscureText: _obscureNew,
              onToggleVisibility: () {
                setState(() => _obscureNew = !_obscureNew);
              },
            ),
            SizedBox(height: 14.h),

            // Confirm Password
            _buildPasswordField(
              context: context,
              controller: _confirmPasswordController,
              label: "নতুন পাসওয়ার্ড নিশ্চিত করুন",
              hintText: "নতুন পাসওয়ার্ড পুনরায় লিখুন",
              obscureText: _obscureConfirm,
              onToggleVisibility: () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
            ),
            SizedBox(height: 24.h),

            CustomActionButton(
              text: "পাসওয়ার্ড আপডেট করুন",
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(fontSize: 14.sp, color: context.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13.sp, color: context.textMuted),
            prefixIcon: Icon(Icons.lock_outline, size: 20.sp, color: context.textMuted),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20.sp,
                color: context.textMuted,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
