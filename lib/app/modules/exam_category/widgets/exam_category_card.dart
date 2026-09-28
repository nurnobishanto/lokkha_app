import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/config/extensions/common_extension.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../styles/text_style.dart';

class ExamCategoryCard extends StatelessWidget {
  final String title;
  final Color? borderColor;
  final Color? iconColor;
  final bool? isIcon;
  final VoidCallback? onTap;

  const ExamCategoryCard({
    super.key,
    required this.title,
    this.borderColor,
    this.iconColor,
    this.isIcon = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: borderColor ??
                (context.isDark
                    ? context.borderColor
                    : LightThemeColors.primaryColor.withValues(alpha: 0.5)),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // center horizontally
          crossAxisAlignment: CrossAxisAlignment.center, //  center vertically
          mainAxisSize: MainAxisSize.min,
          children: [
            isIcon == true
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.5),
                    decoration: BoxDecoration(
                      color: context.primaryLight,
                      borderRadius: const BorderRadius.all(Radius.circular(7.0)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.school,
                        color: iconColor ?? context.primaryColor,
                        size: 25.sp,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            7.w.width,
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading5.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
