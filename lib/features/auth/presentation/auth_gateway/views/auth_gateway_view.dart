import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/utils/phone_utils.dart';
import 'package:lokkha/features/auth/presentation/sign_up/riverpod/sign_up_notifier.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_divider.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_phone_field.dart';
import 'package:lokkha/shared/widgets/app_svg_image.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class AuthGatewayView extends ConsumerStatefulWidget {
  const AuthGatewayView({super.key});

  @override
  ConsumerState<AuthGatewayView> createState() => _AuthGatewayViewState();
}

class _AuthGatewayViewState extends ConsumerState<AuthGatewayView> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _phoneController.text.trim();
    final l10n = context.l10n;

    if (text.isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: l10n.warningTitle,
        message: l10n.providePhoneNumber,
      );
      return;
    }
    if (!PhoneUtils.isValidBdMobile(text)) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: l10n.warningTitle,
        message: l10n.invalidPhoneNumber,
      );
      return;
    }
    ref.read(signUpNotifierProvider.notifier).checkPhoneNumber(text, context);
  }

  void _handleGoogleSignIn() {
    CustomSnackBar.showCustomSnackBar(
      title: 'Google Sign In',
      message: context.l10n.googleSignInComingSoon,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reactively listen to Riverpod states
    ref.watch(localeProvider);
    ref.watch(themeModeProvider);
    final signUpState = ref.watch(signUpNotifierProvider);

    final l10n = context.l10n;
    final textMuted = AppColors.textMuted(context);
    final textSecondary = AppColors.textSecondary(context);
    final primary = context.primaryColor;

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
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 440.w.clamp(320.0, 440.0),
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ─── Top Anchor (Centers Main Content) ────────────
                          const SizedBox.shrink(),

                          // ─── Vertically Centered Main Content ─────────────
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
                                  color: AppColors.card(context),
                                  borderRadius: BorderRadius.circular(22.r),
                                  border: Border.all(
                                    color: AppColors.border(context).withValues(alpha: 0.6),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.08),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
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
                              16.verticalSpace,

                              // ─── Title & Tagline ────────────────────────
                              Text(
                                l10n.authGatewayTagline,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.custom(
                                  fontSize: 23.sp.clamp(20.0, 25.0),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: AppColors.textPrimary(context),
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
                              24.verticalSpace,

                              // ─── Phone Number Input Field ───────────────
                              AuthPhoneField(
                                controller: _phoneController,
                                hintText: l10n.enterPhoneNumber,
                                enabled: !signUpState.isLoading,
                                onSubmitted: (_) => _handleSubmit(),
                              ),
                              12.verticalSpace,

                              // ─── Proceed (এগিয়ে যান) Button ──────────────
                              AuthActionButton.primary(
                                text: l10n.proceed,
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20.r,
                                  color: Colors.white,
                                ),
                                isLoading: signUpState.isLoading,
                                onPressed: _handleSubmit,
                              ),

                              // ─── Minimalist Or Divider ──────────────────
                              AuthDivider(
                                text: l10n.or,
                                verticalPadding: 14.h.clamp(10.0, 16.0),
                              ),

                              // ─── Google Sign-In Button ──────────────────
                              AuthActionButton.secondary(
                                text: l10n.continueWithGoogle,
                                icon: AppSvgImage.asset(
                                  AssetVectorPaths.google,
                                  width: 20.r,
                                  height: 20.r,
                                ),
                                onPressed: _handleGoogleSignIn,
                              ),
                            ],
                          ),

                          // ─── Pinned Bottom Terms & Conditions ─────────────
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                20.verticalSpace,
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: AppTextStyles.custom(
                                      fontSize: 11.5.sp.clamp(10.5, 12.5),
                                      height: 1.5,
                                      color: textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: l10n.termsAgreementNotice,
                                      ),
                                      TextSpan(
                                        text: l10n.termsAndConditions,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: primary.withValues(alpha: 0.5),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            context.push(Routes.termsCondition);
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
