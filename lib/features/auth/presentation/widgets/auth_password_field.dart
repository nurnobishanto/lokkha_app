import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';

/// Clean, minimal, reusable password input field for authentication screens.
/// Matches the dimensions, border radius, and aesthetics of [AuthPhoneField].
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;
  final bool enabled;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.hintText,
    this.onSubmitted,
    this.onChanged,
    this.autoFocus = true,
    this.enabled = true,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = 52.h.clamp(48.0, 56.0);
    final borderRadius = 14.r;
    final primaryColor = context.primaryColor;
    final borderColor = AppColors.border(context);
    final cardColor = AppColors.card(context);
    final textMuted = AppColors.textMuted(context);
    final textPrimary = AppColors.textPrimary(context);

    return Container(
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // ─── Prefix Lock Icon ────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Icon(
              Icons.lock_outline_rounded,
              color: primaryColor,
              size: 20.r.clamp(18.0, 22.0),
            ),
          ),
          Container(
            width: 1.0,
            height: 24.h,
            color: borderColor,
          ),
          12.horizontalSpace,

          // ─── Password Input Field ────────────────────────────
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              autofocus: widget.autoFocus,
              obscureText: _obscureText,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              cursorColor: primaryColor,
              cursorWidth: 1.8,
              style: AppTextStyles.custom(
                fontSize: 15.sp.clamp(14.0, 16.0),
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: _obscureText ? 2.0 : 0.5,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                hintText: widget.hintText ?? context.l10n.enterPassword,
                hintStyle: AppTextStyles.custom(
                  fontSize: 14.sp.clamp(13.0, 15.0),
                  fontWeight: FontWeight.w400,
                  color: textMuted,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),

          // ─── Visibility Toggle Suffix ────────────────────────
          IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: textMuted.withValues(alpha: 0.7),
              size: 20.r,
            ),
            splashRadius: 18.r,
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          4.horizontalSpace,
        ],
      ),
    );
  }
}
