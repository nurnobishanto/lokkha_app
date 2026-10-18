import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/features/profile/data/models/content_history_model.dart';

class LiveContestItemCard extends StatelessWidget {
  final UserContestItemModel item;
  final VoidCallback onViewRanking;
  final VoidCallback onViewResult;

  const LiveContestItemCard({
    super.key,
    required this.item,
    required this.onViewRanking,
    required this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // 1. Header Row (Contest ID Chip, Date, Duration Pill)
          // -------------------------------------------------------------------
          Row(
            children: [
              // Trophy / ID Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF78350F).withValues(alpha: 0.25)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: context.isDark
                        ? const Color(0xFFD97706)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.trophy,
                      size: 11,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "#${item.id}",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: context.isDark
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Date
              Icon(
                Icons.calendar_today_outlined,
                size: 13.sp,
                color: context.textSecondary,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  item.formattedDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Duration Pill (if available)
              if (item.formattedDuration != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11.sp,
                        color: context.textSecondary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        item.formattedDuration!,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 10.h),

          // -------------------------------------------------------------------
          // 2. Contest Title & Score Header
          // -------------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.contestTitle,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Score Banner
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: item.score > 0
                      ? (context.isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                          : const Color(0xFFECFDF5))
                      : (context.isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: item.score > 0
                        ? const Color(0xFF10B981)
                        : context.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14.sp,
                      color: item.score > 0
                          ? const Color(0xFF059669)
                          : context.textSecondary,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "স্কোর: ${item.formattedScore}",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: item.score > 0
                            ? const Color(0xFF059669)
                            : context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // -------------------------------------------------------------------
          // 3. Metrics Row (মোট প্রশ্ন, সঠিক, ভুল, নির্ভুলতা)
          // -------------------------------------------------------------------
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: context.borderColor.withValues(alpha: 0.7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    label: "মোট প্রশ্ন",
                    value: "${item.totalQuestions}",
                    valueColor: context.textPrimary,
                  ),
                ),
                _buildDivider(context),
                Expanded(
                  child: _buildMetricColumn(
                    label: "সঠিক উত্তর",
                    value: "${item.correctAnswers}",
                    valueColor: const Color(0xFF059669),
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                _buildDivider(context),
                Expanded(
                  child: _buildMetricColumn(
                    label: "ভুল উত্তর",
                    value: "${item.incorrectAnswers}",
                    valueColor: const Color(0xFFDC2626),
                    icon: Icons.highlight_off_rounded,
                  ),
                ),
                _buildDivider(context),
                Expanded(
                  child: _buildMetricColumn(
                    label: "মার্কিং",
                    value: "+${item.positiveMark} / -${item.negativeMark}",
                    valueColor: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // -------------------------------------------------------------------
          // 4. Action Buttons (র‍্যাংকিং & ফলাফল)
          // -------------------------------------------------------------------
          Row(
            children: [
              // র‍্যাংকিং দেখুন Button
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewRanking,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: context.isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.rankingStar,
                        size: 13,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          "র‍্যাংকিং",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              // ফলাফল বিশ্লেষণ Button
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          "ফলাফল",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required String label,
    required String value,
    required Color valueColor,
    IconData? icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12.sp, color: valueColor),
                SizedBox(width: 2.w),
              ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 24.h,
      color: context.borderColor,
    );
  }
}
