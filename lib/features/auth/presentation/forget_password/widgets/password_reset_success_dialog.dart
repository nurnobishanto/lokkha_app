import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/features/auth/presentation/widgets/auth_action_button.dart';

class PasswordResetSuccessDialog extends ConsumerWidget {
  final String? phoneNumber;

  const PasswordResetSuccessDialog({
    super.key,
    this.phoneNumber,
  });

  static Future<void> show(BuildContext context, {String? phoneNumber}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PasswordResetSuccessDialog(phoneNumber: phoneNumber),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    ref.watch(themeModeProvider);

    final l10n = context.l10n;
    final primary = context.primaryColor;
    final cardColor = AppColors.card(context);
    final textPrimary = AppColors.textPrimary(context);
    final textMuted = AppColors.textMuted(context);
    final borderColor = AppColors.border(context);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w.clamp(16.0, 32.0)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 380.w.clamp(280.0, 380.0),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24.w.clamp(16.0, 24.0),
            vertical: 28.h.clamp(20.0, 32.0),
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Celebratory Shield Badge ──────────────────────────────
              Container(
                width: 76.r.clamp(64.0, 84.0),
                height: 76.r.clamp(64.0, 84.0),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 52.r.clamp(44.0, 58.0),
                    height: 52.r.clamp(44.0, 58.0),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 30.r.clamp(26.0, 34.0),
                    ),
                  ),
                ),
              ),
              20.verticalSpace,

              // ─── Success Title ─────────────────────────────────────────
              Text(
                l10n.passwordResetSuccessTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.custom(
                  fontSize: 20.sp.clamp(18.0, 22.0),
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              10.verticalSpace,

              // ─── Subtitle Description ──────────────────────────────────
              Text(
                l10n.passwordResetSuccessMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.custom(
                  fontSize: 13.5.sp.clamp(12.5, 14.5),
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: textMuted,
                ),
              ),
              24.verticalSpace,

              // ─── Go to Login Button ────────────────────────────────────
              AuthActionButton.primary(
                text: l10n.goToLogin,
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18.r,
                  color: Colors.white,
                ),
                onPressed: () {
                  ref.read(authRepositoryProvider).logout();
                  Navigator.of(context, rootNavigator: true).pop();
                  context.go(
                    Routes.signIn,
                    extra: phoneNumber != null && phoneNumber!.isNotEmpty
                        ? {'phoneNumber': phoneNumber}
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
