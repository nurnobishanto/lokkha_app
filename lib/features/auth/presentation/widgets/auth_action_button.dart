import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';

/// Clean, professional, reusable authentication action button.
/// Designed for social sign-ins (Google, Apple) and primary auth actions (Phone, Email).
class AuthActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final bool isLoading;
  final bool isOutlined;
  final List<BoxShadow>? elevationShadows;

  const AuthActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.height,
    this.width,
    this.borderRadius,
    this.isLoading = false,
    this.isOutlined = false,
    this.elevationShadows,
  });

  /// Factory constructor for Primary Auth Action (e.g. Phone Sign In)
  factory AuthActionButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
    double? height,
    double? width,
    double? borderRadius,
  }) {
    return AuthActionButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      height: height,
      width: width,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor ?? const Color(0xFF207D62),
      textColor: textColor ?? Colors.white,
      isOutlined: false,
      elevationShadows: [
        BoxShadow(
          color: (backgroundColor ?? const Color(0xFF207D62)).withValues(alpha: 0.22),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Factory constructor for Secondary / Outline / Social Auth Action (e.g. Google Sign In)
  factory AuthActionButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? height,
    double? width,
    double? borderRadius,
  }) {
    return AuthActionButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      height: height,
      width: width,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      isOutlined: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 32.h.clamp(48.0, 56.0);
    final effectiveRadius = borderRadius ?? 14.r;

    final defaultBg = isOutlined
        ? AppColors.card(context)
        : context.primaryColor;
    final effectiveBg = backgroundColor ?? defaultBg;

    final defaultBorder = isOutlined
        ? AppColors.border(context)
        : Colors.transparent;
    final effectiveBorder = borderColor ?? defaultBorder;

    final defaultTextColor = isOutlined
        ? AppColors.textPrimary(context)
        : Colors.white;
    final effectiveTextColor = textColor ?? defaultTextColor;

    return Container(
      width: width ?? double.infinity,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: effectiveBorder,
          width: isOutlined ? 1.2 : 0,
        ),
        boxShadow: elevationShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(effectiveRadius),
          splashColor: (isOutlined
                  ? context.primaryColor
                  : Colors.white)
              .withValues(alpha: 0.12),
          highlightColor: (isOutlined
                  ? context.primaryColor
                  : Colors.white)
              .withValues(alpha: 0.06),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    icon!,
                    12.horizontalSpace,
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.custom(
                        fontSize: 15.sp.clamp(14.0, 16.0),
                        fontWeight: FontWeight.w600,
                        color: effectiveTextColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
