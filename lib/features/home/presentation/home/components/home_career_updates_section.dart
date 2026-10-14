import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';

class HomeCareerUpdatesSection extends StatelessWidget {
  final HomeCareerUpdatesModel careerUpdates;

  const HomeCareerUpdatesSection({
    super.key,
    required this.careerUpdates,
  });

  IconData _getSectorIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'bank':
        return Icons.account_balance_rounded;
      case 'teacher':
        return Icons.school_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'building':
      default:
        return Icons.domain_rounded;
    }
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'green':
        return const Color(0xFF10B981);
      case 'amber':
        return const Color(0xFFF59E0B);
      case 'cyan':
        return const Color(0xFF06B6D4);
      case 'blue':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectors = careerUpdates.jobSectors;
    final jobs = careerUpdates.latestJobs;
    final exams = careerUpdates.latestExams;

    if (sectors.isEmpty && jobs.isEmpty && exams.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header ──────────────────────────────────────────────────────────
        HomeSectionHeader(
          title: 'ক্যারিয়ার ও নিয়োগ আপডেট',
          subtitle: 'সরকারি, ব্যাংক ও স্বায়ত্তশাসিত প্রতিষ্ঠানের সার্কুলার',
          icon: Icons.work_outline_rounded,
          onSeeAll: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.jobs);
            }
          },
        ),

        // ─── Job Sectors ──────────────────────────────────────────────────────
        if (sectors.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectors.take(4).length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 2.5,
              ),
              itemBuilder: (context, index) {
                final sector = sectors[index];
                final color = _getBadgeColor(sector.badgeColor);
                return InkWell(
                  onTap: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(Routes.jobs);
                    }
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: color.withOpacity(0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getSectorIcon(sector.icon),
                            size: 16.sp,
                            color: color,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            sector.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // ─── Latest Jobs Carousel / List ─────────────────────────────────────
        if (jobs.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              'সর্বশেষ নিয়োগ বিজ্ঞপ্তি',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 112.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: jobs.take(5).length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return GestureDetector(
                  onTap: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(Routes.jobs);
                    }
                  },
                  child: Container(
                    width: 220.w,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.borderColor.withOpacity(0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.companyName ?? 'সরকারি নিয়োগ',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: context.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (job.deadlineBn != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  job.deadlineBn!,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Expanded(
                          child: Text(
                            job.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11.sp,
                              color: context.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'আবেদনের শেষ সময়',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: context.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward,
                              size: 12.sp,
                              color: context.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        // ─── Latest Exam Solutions ───────────────────────────────────────────
        if (exams.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              'সাম্প্রতিক পরীক্ষার প্রশ্ন সমাধান',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          ...exams.take(2).map((exam) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: context.borderColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.history_edu_rounded,
                      size: 18.sp,
                      color: context.primaryColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        if (exam.dateBn != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'পরীক্ষার তারিখ: ${exam.dateBn}',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.sp,
                    color: context.textSecondary,
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
