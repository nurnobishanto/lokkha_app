import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/features/auth/presentation/forget_password/riverpod/reset_password_notifier.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_password_field.dart';

class ResetPasswordView extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String otp;

  const ResetPasswordView({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (router != null) {
      router.go(Routes.forgetPassword);
    }
  }

  void _handleUpdatePassword() {
    ref.read(resetPasswordNotifierProvider.notifier).updatePassword(
          phone: widget.phoneNumber,
          otp: widget.otp,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    ref.watch(themeModeProvider);

    final resetState = ref.watch(resetPasswordNotifierProvider);
    final l10n = context.l10n;
    final primary = context.primaryColor;
    final textMuted = AppColors.textMuted(context);
    final textPrimary = AppColors.textPrimary(context);
    final borderColor = AppColors.border(context);
    final cardColor = AppColors.card(context);

    final showMismatch = _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text;

    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 440.w.clamp(320.0, 440.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w.clamp(16.0, 28.0),
                        vertical: 12.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ─── Top Navigation Bar ───────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(12.r),
                                onTap: _handleBack,
                                child: Container(
                                  width: 40.r,
                                  height: 40.r,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: borderColor.withValues(alpha: 0.7),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18.r,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox.shrink(),
                            ],
                          ),
                          20.verticalSpace,

                          // ─── Minimal Lock Badge ───────────────────────────
                          Container(
                            width: 76.r.clamp(64.0, 84.0),
                            height: 76.r.clamp(64.0, 84.0),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primary.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.lock_outline_rounded,
                                size: 36.r.clamp(30.0, 42.0),
                                color: primary,
                              ),
                            ),
                          ),
                          20.verticalSpace,

                          // ─── Title & Subtitle ─────────────────────────────
                          Text(
                            l10n.createNewPassword,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.custom(
                              fontSize: 22.sp.clamp(20.0, 24.0),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: textPrimary,
                            ),
                          ),
                          8.verticalSpace,
                          Text(
                            l10n.createNewPasswordSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.custom(
                              fontSize: 13.5.sp.clamp(12.5, 14.5),
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              color: textMuted,
                            ),
                          ),
                          24.verticalSpace,

                          // ─── New Password Field ───────────────────────────
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.newPassword,
                              style: AppTextStyles.custom(
                                fontSize: 13.5.sp.clamp(12.5, 14.5),
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          8.verticalSpace,
                          AuthPasswordField(
                            controller: _passwordController,
                            hintText: l10n.newPassword,
                            enabled: !resetState.isLoading,
                            onChanged: (val) {
                              ref
                                  .read(resetPasswordNotifierProvider.notifier)
                                  .setPassword(val);
                            },
                          ),
                          16.verticalSpace,

                          // ─── Confirm Password Field ───────────────────────
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.confirmPassword,
                              style: AppTextStyles.custom(
                                fontSize: 13.5.sp.clamp(12.5, 14.5),
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          8.verticalSpace,
                          AuthPasswordField(
                            controller: _confirmPasswordController,
                            hintText: l10n.confirmPassword,
                            enabled: !resetState.isLoading,
                            onChanged: (val) {
                              ref
                                  .read(resetPasswordNotifierProvider.notifier)
                                  .setConfirmPassword(val);
                            },
                            onSubmitted: (_) => _handleUpdatePassword(),
                          ),

                          // ─── Real-time Mismatch Error ─────────────────────
                          if (showMismatch) ...[
                            8.verticalSpace,
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 15.r,
                                  color: AppColors.danger(context),
                                ),
                                6.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    l10n.passwordsDoNotMatch,
                                    style: AppTextStyles.custom(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.danger(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          24.verticalSpace,

                          // ─── Action Button (Update Password) ──────────────
                          AuthActionButton.primary(
                            text: l10n.updatePassword,
                            icon: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18.r,
                              color: Colors.white,
                            ),
                            isLoading: resetState.isLoading,
                            onPressed: _handleUpdatePassword,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
