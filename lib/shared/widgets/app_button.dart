import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';

/// Design system button visual variants.
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
}

/// Design system button sizes.
enum AppButtonSize {
  sm,
  md,
  lg,
}

/// A comprehensive, theme-aware, modern button component.
/// Provides consistent typography, padding, ripple effects, loading state,
/// and accessibility across the entire app.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? height;
  final double? width;
  final TextStyle? textStyle;
  final List<BoxShadow>? elevationShadows;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.height,
    this.width,
    this.textStyle,
    this.elevationShadows,
  });

  /// Factory constructor for Primary Button
  const factory AppButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size,
    Widget? icon,
    Widget? trailingIcon,
    bool isLoading,
    bool isFullWidth,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    double? height,
    double? width,
    TextStyle? textStyle,
    List<BoxShadow>? elevationShadows,
  }) = _AppButtonPrimary;

  /// Factory constructor for Secondary (Tinted) Button
  const factory AppButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size,
    Widget? icon,
    Widget? trailingIcon,
    bool isLoading,
    bool isFullWidth,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? borderRadius,
    double? height,
    double? width,
    TextStyle? textStyle,
  }) = _AppButtonSecondary;

  /// Factory constructor for Outline Button
  const factory AppButton.outline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size,
    Widget? icon,
    Widget? trailingIcon,
    bool isLoading,
    bool isFullWidth,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? borderRadius,
    double? height,
    double? width,
    TextStyle? textStyle,
  }) = _AppButtonOutline;

  /// Factory constructor for Text / Ghost Button
  const factory AppButton.text({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size,
    Widget? icon,
    Widget? trailingIcon,
    bool isLoading,
    bool isFullWidth,
    Color? textColor,
    TextStyle? textStyle,
  }) = _AppButtonText;

  /// Factory constructor for Destructive / Danger Button
  const factory AppButton.danger({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size,
    Widget? icon,
    Widget? trailingIcon,
    bool isLoading,
    bool isFullWidth,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    double? height,
    double? width,
    TextStyle? textStyle,
  }) = _AppButtonDanger;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    // 1. Calculate dimensions based on size
    final double defaultHeight;
    final double defaultRadius;
    final double defaultFontSize;
    final EdgeInsetsGeometry horizontalPadding;

    switch (size) {
      case AppButtonSize.sm:
        defaultHeight = 32.h;
        defaultRadius = 6.r;
        defaultFontSize = 12.sp;
        horizontalPadding = EdgeInsets.symmetric(horizontal: 10.w);
        break;
      case AppButtonSize.lg:
        defaultHeight = 52.h;
        defaultRadius = 12.r;
        defaultFontSize = 16.sp;
        horizontalPadding = EdgeInsets.symmetric(horizontal: 20.w);
        break;
      case AppButtonSize.md:
      defaultHeight = 44.h;
        defaultRadius = 10.r;
        defaultFontSize = 14.sp;
        horizontalPadding = EdgeInsets.symmetric(horizontal: 16.w);
        break;
    }

    final effectiveHeight = height ?? defaultHeight;
    final effectiveRadius = borderRadius ?? defaultRadius;

    // 2. Resolve colors based on variant and active theme
    Color resolvedBg;
    Color resolvedText;
    Color resolvedBorder;

    switch (variant) {
      case AppButtonVariant.primary:
        resolvedBg = backgroundColor ?? context.primaryColor;
        resolvedText = textColor ?? Colors.white;
        resolvedBorder = borderColor ?? Colors.transparent;
        break;
      case AppButtonVariant.secondary:
        resolvedBg = backgroundColor ??
            context.primaryColor.withValues(alpha: context.isDark ? 0.20 : 0.10);
        resolvedText = textColor ?? context.primaryColor;
        resolvedBorder = borderColor ?? Colors.transparent;
        break;
      case AppButtonVariant.outline:
        resolvedBg = backgroundColor ?? context.cardColor;
        resolvedText = textColor ?? context.textPrimary;
        resolvedBorder = borderColor ?? AppColors.border(context);
        break;
      case AppButtonVariant.text:
        resolvedBg = backgroundColor ?? Colors.transparent;
        resolvedText = textColor ?? context.primaryColor;
        resolvedBorder = borderColor ?? Colors.transparent;
        break;
      case AppButtonVariant.danger:
        resolvedBg = backgroundColor ?? AppColors.danger(context);
        resolvedText = textColor ?? Colors.white;
        resolvedBorder = borderColor ?? Colors.transparent;
        break;
    }

    if (isDisabled) {
      resolvedBg = resolvedBg.withValues(alpha: 0.55);
      resolvedText = resolvedText.withValues(alpha: 0.55);
      if (resolvedBorder != Colors.transparent) {
        resolvedBorder = resolvedBorder.withValues(alpha: 0.55);
      }
    }

    // 3. Splash and Highlight feedback
    final splashColor = (variant == AppButtonVariant.primary ||
            variant == AppButtonVariant.danger)
        ? Colors.white.withValues(alpha: 0.15)
        : context.primaryColor.withValues(alpha: 0.12);

    final widgetContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: (defaultFontSize + 6).r,
            height: (defaultFontSize + 6).r,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedText),
            ),
          )
        else ...[
          if (icon != null) ...[
            icon!,
            SizedBox(width: 8.w),
          ],
          Flexible(
            fit: isFullWidth ? FlexFit.loose : FlexFit.loose,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle ??
                  AppTextStyles.custom(
                    fontSize: defaultFontSize,
                    fontWeight: FontWeight.w600,
                    color: resolvedText,
                  ),
            ),
          ),
          if (trailingIcon != null) ...[
            SizedBox(width: 8.w),
            trailingIcon!,
          ],
        ],
      ],
    );

    return Container(
      width: isFullWidth ? (width ?? double.infinity) : width,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: resolvedBorder != Colors.transparent
            ? Border.all(color: resolvedBorder, width: 1.2)
            : null,
        boxShadow: elevationShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(effectiveRadius),
          splashColor: splashColor,
          highlightColor: splashColor.withValues(alpha: 0.05),
          child: Padding(
            padding: horizontalPadding,
            child: widgetContent,
          ),
        ),
      ),
    );
  }
}

class _AppButtonPrimary extends AppButton {
  const _AppButtonPrimary({
    super.key,
    required super.text,
    required super.onPressed,
    super.size = AppButtonSize.md,
    super.icon,
    super.trailingIcon,
    super.isLoading = false,
    super.isFullWidth = true,
    super.backgroundColor,
    super.textColor,
    super.borderRadius,
    super.height,
    super.width,
    super.textStyle,
    super.elevationShadows,
  }) : super(variant: AppButtonVariant.primary);
}

class _AppButtonSecondary extends AppButton {
  const _AppButtonSecondary({
    super.key,
    required super.text,
    required super.onPressed,
    super.size = AppButtonSize.md,
    super.icon,
    super.trailingIcon,
    super.isLoading = false,
    super.isFullWidth = true,
    super.backgroundColor,
    super.textColor,
    super.borderColor,
    super.borderRadius,
    super.height,
    super.width,
    super.textStyle,
  }) : super(variant: AppButtonVariant.secondary);
}

class _AppButtonOutline extends AppButton {
  const _AppButtonOutline({
    super.key,
    required super.text,
    required super.onPressed,
    super.size = AppButtonSize.md,
    super.icon,
    super.trailingIcon,
    super.isLoading = false,
    super.isFullWidth = true,
    super.backgroundColor,
    super.textColor,
    super.borderColor,
    super.borderRadius,
    super.height,
    super.width,
    super.textStyle,
  }) : super(variant: AppButtonVariant.outline);
}

class _AppButtonText extends AppButton {
  const _AppButtonText({
    super.key,
    required super.text,
    required super.onPressed,
    super.size = AppButtonSize.md,
    super.icon,
    super.trailingIcon,
    super.isLoading = false,
    super.isFullWidth = false,
    super.textColor,
    super.textStyle,
  }) : super(
          variant: AppButtonVariant.text,
          backgroundColor: Colors.transparent,
        );
}

class _AppButtonDanger extends AppButton {
  const _AppButtonDanger({
    super.key,
    required super.text,
    required super.onPressed,
    super.size = AppButtonSize.md,
    super.icon,
    super.trailingIcon,
    super.isLoading = false,
    super.isFullWidth = true,
    super.backgroundColor,
    super.textColor,
    super.borderRadius,
    super.height,
    super.width,
    super.textStyle,
  }) : super(variant: AppButtonVariant.danger);
}
