import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/phone_utils.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:pinput/pinput.dart';
import '../riverpod/verify_otp_notifier.dart';

class VerifyOtpView extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String type;
  final bool autoStartTimer;
  final bool autoSendOtp;
  final int initialExpiresIn;
  final String? serverOtp;

  const VerifyOtpView({
    super.key,
    this.phoneNumber = '',
    this.type = 'Registration',
    this.autoStartTimer = true,
    this.autoSendOtp = true,
    this.initialExpiresIn = 300,
    this.serverOtp,
  });

  @override
  ConsumerState<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends ConsumerState<VerifyOtpView> {
  late final TextEditingController _pinController;
  Timer? _resendTimer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _remainingSeconds = widget.initialExpiresIn;
    if (widget.autoStartTimer) {
      _startResendTimer(widget.initialExpiresIn);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.serverOtp != null && widget.serverOtp!.isNotEmpty) {
        ref
            .read(verifyOtpNotifierProvider.notifier)
            .setServerOtp(widget.serverOtp);
      }
      if (widget.autoSendOtp && widget.phoneNumber.isNotEmpty) {
        ref
            .read(verifyOtpNotifierProvider.notifier)
            .sendOtp(widget.phoneNumber, widget.type);
      }
    });
  }

  @override
  void didUpdateWidget(covariant VerifyOtpView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialExpiresIn != widget.initialExpiresIn) {
      _remainingSeconds = widget.initialExpiresIn;
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void _startResendTimer([int? seconds]) {
    _resendTimer?.cancel();
    if (!mounted) return;
    final total = seconds ?? ref.read(verifyOtpNotifierProvider).expiresIn;
    setState(() {
      _remainingSeconds = total > 0 ? total : 300;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleResendOtp() {
    if (_remainingSeconds > 0) return;
    _startResendTimer();
    ref
        .read(verifyOtpNotifierProvider.notifier)
        .sendOtp(widget.phoneNumber, widget.type);
  }

  void _handleVerify() {
    final otp = _pinController.text.trim();
    final l10n = context.l10n;

    if (otp.length < 6) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: l10n.warningTitle,
        message: l10n.otpRequired,
      );
      return;
    }

    final isForgetPassword =
        widget.type.toLowerCase().contains('forget') ||
        widget.type.toLowerCase().contains('forgot') ||
        widget.type.toLowerCase().contains('reset');

    ref.read(verifyOtpNotifierProvider.notifier).setOtp(otp);

    if (widget.type == 'Registration') {
      ref
          .read(verifyOtpNotifierProvider.notifier)
          .register(widget.phoneNumber, context);
    } else if (isForgetPassword) {
      ref
          .read(verifyOtpNotifierProvider.notifier)
          .verifyOtpForReset(widget.phoneNumber, context, otp: otp);
    } else {
      ref
          .read(verifyOtpNotifierProvider.notifier)
          .loginWithOtp(widget.phoneNumber, context);
    }
  }

  void _handleBack() {
    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (router != null) {
      final isForgetPassword =
          widget.type.toLowerCase().contains('forget') ||
          widget.type.toLowerCase().contains('forgot') ||
          widget.type.toLowerCase().contains('reset');
      if (isForgetPassword) {
        router.go(Routes.forgetPassword);
      } else {
        router.go(Routes.signIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    ref.watch(themeModeProvider);
    final verifyOtpState = ref.watch(verifyOtpNotifierProvider);

    // Synchronize timer whenever sendOtp completes with new expiresIn
    ref.listen<VerifyOtpState>(verifyOtpNotifierProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading && next.errorMessage == null) {
        _startResendTimer(next.expiresIn);
      }
    });

    final l10n = context.l10n;
    final primary = context.primaryColor;
    final textMuted = AppColors.textMuted(context);
    final textPrimary = AppColors.textPrimary(context);
    final borderColor = AppColors.border(context);
    final cardColor = AppColors.card(context);

    // Format phone display
    final rawPhone = widget.phoneNumber.isNotEmpty
        ? PhoneUtils.toLocal11Digit(widget.phoneNumber)
        : '';
    final displayPhone = rawPhone.length == 11
        ? '${rawPhone.substring(0, 5)} ${rawPhone.substring(5)}'
        : rawPhone;

    // Pin theme configurations
    final defaultPinTheme = PinTheme(
      width: 44.w.clamp(36.0, 48.0),
      height: 52.h.clamp(46.0, 56.0),
      textStyle: AppTextStyles.custom(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.8),
          width: 1.2,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: primary,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: primary.withValues(alpha: 0.8),
          width: 1.4,
        ),
      ),
    );

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

                          // ─── Minimal Security Badge ───────────────────────
                          Container(
                            width: 84.r.clamp(72.0, 92.0),
                            height: 84.r.clamp(72.0, 92.0),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24.r),
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
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 50.r,
                                height: 50.r,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Icon(
                                  Icons.mark_email_read_outlined,
                                  size: 28.r,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),
                          20.verticalSpace,

                          // ─── Tagline & Subtitle ──────────────────────────
                          Text(
                            l10n.otpVerification,
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
                            l10n.otpSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.custom(
                              fontSize: 13.5.sp.clamp(12.5, 14.5),
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              color: textMuted,
                            ),
                          ),
                          16.verticalSpace,

                          // ─── Verified Phone Number Card ───────────────────
                          if (rawPhone.isNotEmpty)
                            Container(
                              height: 52.h.clamp(48.0, 56.0),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w.clamp(10.0, 16.0),
                              ),
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
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 1.0,
                                    height: 24.h,
                                    color: borderColor,
                                  ),
                                  const SizedBox(width: 10),
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
                                    onTap: _handleBack,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w.clamp(4.0, 8.0),
                                        vertical: 6.h.clamp(4.0, 8.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 14.r,
                                            color: primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n.changePhone,
                                            style: AppTextStyles.custom(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          20.verticalSpace,

                          // ─── 6-Digit Pinput Field ─────────────────────────
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Pinput(
                              controller: _pinController,
                              autofocus: true,
                              length: 6,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              separatorBuilder: (_) => 6.horizontalSpace,
                              pinputAutovalidateMode: PinputAutovalidateMode.disabled,
                              showCursor: true,
                              cursor: Container(
                                width: 2,
                                height: 24.h,
                                color: primary,
                              ),
                              onCompleted: (pin) {
                                ref
                                    .read(verifyOtpNotifierProvider.notifier)
                                    .setOtp(pin);
                                _handleVerify();
                              },
                              onChanged: (pin) {
                                ref
                                    .read(verifyOtpNotifierProvider.notifier)
                                    .setOtp(pin);
                              },
                            ),
                          ),
                          20.verticalSpace,

                          // ─── Resend Code / Countdown Timer ───────────────
                          if (_remainingSeconds > 0)
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 15.r,
                                  color: textMuted,
                                ),
                                6.horizontalSpace,
                                Text(
                                  l10n.resendCodeIn(
                                    _formatTimer(_remainingSeconds),
                                  ),
                                  style: AppTextStyles.custom(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            )
                          else
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  l10n.didNotReceiveCode,
                                  style: AppTextStyles.custom(
                                    fontSize: 13.sp,
                                    color: textMuted,
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(6.r),
                                  onTap: _handleResendOtp,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 2.h,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.refresh_rounded,
                                          size: 15.r,
                                          color: primary,
                                        ),
                                        4.horizontalSpace,
                                        Text(
                                          l10n.resendOtp,
                                          style: AppTextStyles.custom(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          20.verticalSpace,

                          // ─── Verify Action Button ─────────────────────────
                          AuthActionButton.primary(
                            text: l10n.verify,
                            isLoading: verifyOtpState.isLoading,
                            onPressed: _handleVerify,
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
