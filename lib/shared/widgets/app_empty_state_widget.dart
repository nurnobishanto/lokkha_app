import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';

/// Reusable empty state widget for lists, search results and feeds.
class AppEmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyStateWidget({
    super.key,
    this.title = 'কোন তথ্য পাওয়া যায়নি',
    this.subtitle,
    this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon ??
                Icon(
                  Icons.inbox_outlined,
                  size: 64.r,
                  color: context.textMuted.withValues(alpha: 0.5),
                ),
            16.height,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading4.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              8.height,
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body2.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
            if (actionText != null && onAction != null) ...[
              20.height,
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
