import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/phone_utils.dart';
import 'package:lokkha/features/auth/presentation/forget_password/riverpod/forget_password_notifier.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_phone_field.dart';

class ForgetPasswordView extends ConsumerStatefulWidget {
  final String? initialPhoneNumber;

  const ForgetPasswordView({
    super.key,
    this.initialPhoneNumber,
  });

  @override
  ConsumerState<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends ConsumerState<ForgetPasswordView> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPhoneNumber != null
        ? PhoneUtils.toLocal11Digit(widget.initialPhoneNumber!)
        : '';
    _phoneController = TextEditingController(text: initial);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initial.isNotEmpty) {
        ref.read(forgetPasswordNotifierProvider.notifier).setPhone(initial);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (router != null) {
      router.go(Routes.signIn);
    }
  }

  void _handleSendOtp() {
    ref.read(forgetPasswordNotifierProvider.notifier).sendOtp(
          context: context,
          phoneOverride: _phoneController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    ref.watch(themeModeProvider);

    final forgetPasswordState = ref.watch(forgetPasswordNotifierProvider);
    final l10n = context.l10n;
    final primary = context.primaryColor;
    final textMuted = AppColors.textMuted(context);
    final textPrimary = AppColors.textPrimary(context);
    final borderColor = AppColors.border(context);
    final cardColor = AppColors.card(context);

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

                          // ─── Minimal Icon Badge ───────────────────────────
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
                                Icons.lock_reset_rounded,
                                size: 36.r.clamp(30.0, 42.0),
                                color: primary,
                              ),
                            ),
                          ),
                          20.verticalSpace,

                          // ─── Title & Subtitle ─────────────────────────────
                          Text(
                            l10n.forgotPassword,
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
                            l10n.forgotPasswordSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.custom(
                              fontSize: 13.5.sp.clamp(12.5, 14.5),
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              color: textMuted,
                            ),
                          ),
                          24.verticalSpace,

                          // ─── Phone Number Input Field ─────────────────────
                          AuthPhoneField(
                            controller: _phoneController,
                            hintText: l10n.enterPhoneNumber,
                            enabled: !forgetPasswordState.isLoading,
                            onChanged: (val) {
                              ref
                                  .read(forgetPasswordNotifierProvider.notifier)
                                  .setPhone(val);
                            },
                            onSubmitted: (_) => _handleSendOtp(),
                          ),
                          24.verticalSpace,

                          // ─── Action Button (Send OTP) ──────────────────────
                          AuthActionButton.primary(
                            text: l10n.sendOtpAction,
                            icon: Icon(
                              Icons.arrow_forward_rounded,
                              size: 18.r,
                              color: Colors.white,
                            ),
                            isLoading: forgetPasswordState.isLoading,
                            onPressed: _handleSendOtp,
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
