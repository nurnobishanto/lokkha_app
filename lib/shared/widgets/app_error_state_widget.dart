import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';

/// Reusable error state widget with retry callback.
class AppErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  const AppErrorStateWidget({
    super.key,
    this.message = 'কিছু সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
    this.onRetry,
    this.retryText = 'আবার চেষ্টা করুন',
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
            Icon(
              Icons.error_outline_rounded,
              size: 56.r,
              color: context.dangerColor,
            ),
            16.height,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body1.copyWith(
                color: context.textPrimary,
              ),
            ),
            if (onRetry != null) ...[
              20.height,
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryText),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primaryColor,
                  side: BorderSide(color: context.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
