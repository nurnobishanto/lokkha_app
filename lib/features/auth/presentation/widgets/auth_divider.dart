import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';

/// Clean, minimal reusable divider with centered label (e.g. "অথবা" / "or").
class AuthDivider extends StatelessWidget {
  final String? text;
  final double? verticalPadding;

  const AuthDivider({
    super.key,
    this.text,
    this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = AppColors.border(context);
    final textColor = AppColors.textMuted(context);
    final displayText = text ?? context.l10n.or;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? 16.h.clamp(12.0, 24.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    dividerColor.withValues(alpha: 0.0),
                    dividerColor,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              displayText,
              style: AppTextStyles.custom(
                fontSize: 13.sp.clamp(12.0, 14.0),
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    dividerColor,
                    dividerColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
