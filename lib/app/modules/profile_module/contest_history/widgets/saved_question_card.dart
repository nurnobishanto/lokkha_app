import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/saved_question_item_model.dart';

class SavedQuestionCard extends StatelessWidget {
  final SavedQuestionItemModel item;
  final VoidCallback onTap;

  const SavedQuestionCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            // Bookmark Icon Container
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.bookmark_rounded,
                size: 20.sp,
                color: const Color(0xFF059669),
              ),
            ),

            SizedBox(width: 12.w),

            // Question Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "প্রশ্ন #${item.id}",
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "সেভ করা হয়েছে: ${item.savedDate}",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
