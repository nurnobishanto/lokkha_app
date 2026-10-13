import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';

/// Clean, minimal, reusable phone number input field for authentication screens.
/// Matches the dimensions and styling of [AuthActionButton].
class AuthPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;
  final bool enabled;

  const AuthPhoneField({
    super.key,
    required this.controller,
    this.hintText,
    this.onSubmitted,
    this.onChanged,
    this.autoFocus = false,
    this.enabled = true,
  });

  @override
  State<AuthPhoneField> createState() => _AuthPhoneFieldState();
}

class _AuthPhoneFieldState extends State<AuthPhoneField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      if (mounted) {
        setState(() {
          _hasText = hasText;
        });
      }
    }
  }

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
          // ─── Prefix Icon / Country Indicator ─────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Icon(
              Icons.phone_iphone_rounded,
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

          // ─── Input Field ─────────────────────────────────────
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              autofocus: widget.autoFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              cursorColor: primaryColor,
              cursorWidth: 1.8,
              style: AppTextStyles.custom(
                fontSize: 15.sp.clamp(14.0, 16.0),
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                hintText: widget.hintText ?? context.l10n.enterPhoneNumber,
                hintStyle: AppTextStyles.custom(
                  fontSize: 14.sp.clamp(13.0, 15.0),
                  fontWeight: FontWeight.w400,
                  color: textMuted,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),

          // ─── Clear Icon ──────────────────────────────────────
          if (_hasText && widget.enabled)
            IconButton(
              icon: Icon(
                Icons.cancel_rounded,
                color: textMuted.withValues(alpha: 0.6),
                size: 18.r,
              ),
              splashRadius: 18.r,
              onPressed: () {
                widget.controller.clear();
                widget.onChanged?.call('');
              },
            )
          else
            10.horizontalSpace,
        ],
      ),
    );
  }
}
