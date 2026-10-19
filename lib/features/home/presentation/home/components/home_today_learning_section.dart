import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';

class HomeTodayLearningSection extends StatelessWidget {
  final HomeActiveContest? activeContest;

  const HomeTodayLearningSection({
    super.key,
    this.activeContest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 12.h),

        // ─── Header ──────────────────────────────────────────────────────────
        Text(
          "Today's Learning",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),

        SizedBox(height: 6.h),

        // ─── Stats Subtitles ─────────────────────────────────────────────────
        Text(
          "Total Free Exams: 04 | Remaining: 10",
          style: TextStyle(
            fontSize: 11.5.sp,
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Total Marks: ",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: context.textSecondary,
                ),
              ),
              TextSpan(
                text: "200",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              TextSpan(
                text: " | Total Duration: ",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: context.textSecondary,
                ),
              ),
              TextSpan(
                text: "60m",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          "Total Exam Given: 07",
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0D9488),
          ),
        ),

        SizedBox(height: 12.h),

        // ─── Exam Card 1 ─────────────────────────────────────────────────────
        _LearningExamCard(
          title: activeContest?.name.isNotEmpty == true
              ? activeContest!.name
              : "ডেইলি কুইজ [১০০ পি]",
          badgeText: activeContest?.isLive == true ? "Live" : "Contest",
          categoryTag: "সাধারণ বিষয়াবলি",
          description: activeContest?.description?.isNotEmpty == true
              ? activeContest!.description!
              : "বিসিএস প্রিলিমিনারি ও অন্যান্য প্রতিযোগিতামূলক পরীক্ষার জন্য বিগত বছরের প্রশ্ন ও ব্যাখ্যাসহ প্রস্তুতি...",
          marks: activeContest != null && activeContest!.autoQuestionCount > 0
              ? "${activeContest!.autoQuestionCount} Marks"
              : "100 Marks",
          duration: activeContest != null && activeContest!.durationMinutes > 0
              ? "${activeContest!.durationMinutes} Min"
              : "15 Min",
          studyResourcesCount: 4,
          onPracticeTap: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.fastPractice);
            }
          },
          onJoinExamTap: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.contest);
            }
          },
        ),

        SizedBox(height: 10.h),

        // ─── Exam Card 2 ─────────────────────────────────────────────────────
        _LearningExamCard(
          title: "ব্যাংক নিয়োগ প্রস্তুতি - লং কোর্স",
          badgeText: "Exam 42",
          categoryTag: "সাধারণ বিষয়াবলি",
          description:
              "সমন্বিত ৮ ব্যাংক ও বাংলাদেশ ব্যাংক অফিসার পদের সাধারণ জ্ঞান ও গণিত বিষয়ের পূর্ণাঙ্গ মডেল টেস্ট...",
          marks: "100 Marks",
          duration: "15 Min",
          studyResourcesCount: 4,
          onPracticeTap: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.fastPractice);
            }
          },
          onJoinExamTap: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.allExam);
            }
          },
        ),
      ],
    );
  }
}

class _LearningExamCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final String categoryTag;
  final String description;
  final String marks;
  final String duration;
  final int studyResourcesCount;
  final VoidCallback onPracticeTap;
  final VoidCallback onJoinExamTap;

  const _LearningExamCard({
    required this.title,
    required this.badgeText,
    required this.categoryTag,
    required this.description,
    required this.marks,
    required this.duration,
    required this.studyResourcesCount,
    required this.onPracticeTap,
    required this.onJoinExamTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Green Accent Stripe
              Container(
                width: 5.w,
                color: const Color(0xFF0D9488),
              ),

              // Main Card Body
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title + Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: context.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      // Category Tag
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          categoryTag,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Description
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: context.textSecondary,
                          height: 1.35,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Marks & Duration Row
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14.sp,
                            color: const Color(0xFF10B981),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            marks,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Icon(
                            Icons.access_time_rounded,
                            size: 14.sp,
                            color: const Color(0xFF0D9488),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            duration,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // Study Resources Button
                      InkWell(
                        onTap: () {
                          if (GoRouter.maybeOf(context) != null) {
                            context.push(Routes.lectureSheet);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.folder_open_rounded,
                                size: 13.sp,
                                color: const Color(0xFFD97706),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "Study Resources ($studyResourcesCount) >",
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Bottom Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onPracticeTap,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF0D9488),
                                  width: 1.2,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              child: Text(
                                "প্র্যাকটিস কুইজ",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D9488),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onJoinExamTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D9488),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              child: Text(
                                "লাইভ পরীক্ষায় অংশ দিন",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
