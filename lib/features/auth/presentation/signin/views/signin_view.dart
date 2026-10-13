import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/utils/phone_utils.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import '../riverpod/sign_in_notifier.dart';

class SignInView extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String type;

  const SignInView({
    super.key,
    this.phoneNumber = '',
    this.type = 'password',
  });

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final password = _passwordController.text.trim();
    final l10n = context.l10n;

    if (password.isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: l10n.warningTitle,
        message: l10n.providePassword,
      );
      return;
    }

    ref.read(signInNotifierProvider.notifier).login(
          phone: widget.phoneNumber,
          type: widget.type,
          password: password,
          context: context,
        );
  }

  void _handleNavigateToOtp() {
    context.push(
      Routes.verifyOtp,
      extra: {
        'phoneNumber': widget.phoneNumber,
        'type': 'Login',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    ref.watch(themeModeProvider);
    final signInState = ref.watch(signInNotifierProvider);

    final l10n = context.l10n;
    final primary = context.primaryColor;
    final textMuted = AppColors.textMuted(context);
    final textPrimary = AppColors.textPrimary(context);
    final borderColor = AppColors.border(context);
    final cardColor = AppColors.card(context);

    // Format phone number for clean readable display
    final displayPhone = widget.phoneNumber.isNotEmpty
        ? PhoneUtils.toLocal11Digit(widget.phoneNumber)
        : '';

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
                        horizontal: 24.w,
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
                                onTap: () => Navigator.of(context).maybePop(),
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

                          // ─── Main Content (Positioned Nicely at the Top) ──
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ─── Minimal Brand Card ──────────────────────
                              Container(
                                width: 84.r.clamp(72.0, 92.0),
                                height: 84.r.clamp(72.0, 92.0),
                                padding: EdgeInsets.all(14.r),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(22.r),
                                  border: Border.all(
                                    color: borderColor.withValues(alpha: 0.6),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.08),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Image.asset(
                                    AssetImagePaths.appIcon,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              20.verticalSpace,

                              // ─── Tagline & Subtitle ──────────────────────
                              Text(
                                l10n.authGatewayTagline,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.custom(
                                  fontSize: 23.sp.clamp(20.0, 25.0),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: textPrimary,
                                ),
                              ),
                              6.verticalSpace,
                              Text(
                                l10n.authGatewaySubtitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.custom(
                                  fontSize: 13.5.sp.clamp(12.5, 14.5),
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                  color: textMuted,
                                ),
                              ),
                              20.verticalSpace,

                              // ─── Section Header ──────────────────────────
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  l10n.loginWithPhoneNumber,
                                  style: AppTextStyles.custom(
                                    fontSize: 14.5.sp.clamp(13.5, 15.5),
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                              12.verticalSpace,

                              // ─── Verified Phone Number Card ──────────────
                              Container(
                                height: 52.h.clamp(48.0, 56.0),
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone_iphone_rounded,
                                      color: primary,
                                      size: 20.r.clamp(18.0, 22.0),
                                    ),
                                    14.horizontalSpace,
                                    Container(
                                      width: 1.0,
                                      height: 24.h,
                                      color: borderColor,
                                    ),
                                    12.horizontalSpace,
                                    Expanded(
                                      child: Text(
                                        displayPhone,
                                        style: AppTextStyles.custom(
                                          fontSize: 15.sp.clamp(14.0, 16.0),
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8.r),
                                      onTap: () =>
                                          Navigator.of(context).maybePop(),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 4.h,
                                        ),
                                        child: Text(
                                          l10n.changePhone,
                                          style: AppTextStyles.custom(
                                            fontSize: 12.sp.clamp(11.0, 13.0),
                                            fontWeight: FontWeight.w600,
                                            color: primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              12.verticalSpace,

                              // ─── Password Field ──────────────────────────
                              AuthPasswordField(
                                controller: _passwordController,
                                hintText: l10n.enterPassword,
                                enabled: !signInState.isLoading,
                                onSubmitted: (_) => _handleLogin(),
                              ),
                              10.verticalSpace,

                              // ─── Forgot Password / OTP Option ───────────
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6.r),
                                  onTap: _handleNavigateToOtp,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.h,
                                      horizontal: 2.w,
                                    ),
                                    child: Text(
                                      l10n.forgotPasswordOrOtp,
                                      style: AppTextStyles.custom(
                                        fontSize: 12.sp.clamp(11.0, 13.0),
                                        fontWeight: FontWeight.w600,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              20.verticalSpace,

                              // ─── Login Button ────────────────────────────
                              AuthActionButton.primary(
                                text: l10n.proceed,
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20.r,
                                  color: Colors.white,
                                ),
                                isLoading: signInState.isLoading,
                                onPressed: _handleLogin,
                              ),
                            ],
                          ),

                          // ─── Bottom Spacing Anchor ────────────────────────
                          20.verticalSpace,
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
