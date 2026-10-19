import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';

class HomeQuickLinksSection extends StatelessWidget {
  const HomeQuickLinksSection({super.key});

  static const List<({
    String title,
    IconData icon,
    Color iconColor,
    String route,
  })> links = [
    (
      title: 'বিষয়ভিত্তিক পরীক্ষা',
      icon: Icons.checklist_rtl_rounded,
      iconColor: Color(0xFF10B981),
      route: Routes.mockTestTab,
    ),
    (
      title: 'PDF Section',
      icon: Icons.picture_as_pdf_rounded,
      iconColor: Color(0xFFEF4444),
      route: Routes.lectureSheet,
    ),
    (
      title: 'মডেল টেস্ট',
      icon: Icons.assignment_turned_in_rounded,
      iconColor: Color(0xFF0D9488),
      route: Routes.allExam,
    ),
    (
      title: 'Book Store',
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFFF59E0B),
      route: Routes.questionBank,
    ),
    (
      title: 'স্পেশাল ব্যাচ',
      icon: Icons.stars_rounded,
      iconColor: Color(0xFF3B82F6),
      route: Routes.courses,
    ),
    (
      title: 'Question Archive',
      icon: Icons.inventory_2_rounded,
      iconColor: Color(0xFFD97706),
      route: Routes.questionBank,
    ),
    (
      title: 'Live Exam',
      icon: Icons.sensors_rounded,
      iconColor: Color(0xFFE11D48),
      route: Routes.allContest,
    ),
    (
      title: 'Contest Reports',
      icon: Icons.analytics_rounded,
      iconColor: Color(0xFF0284C7),
      route: Routes.contestHistory,
    ),
    (
      title: 'পরীক্ষার রুটিন ও ফলাফল',
      icon: Icons.calendar_month_rounded,
      iconColor: Color(0xFF6366F1),
      route: Routes.latestExam,
    ),
    (
      title: 'সর্বশেষ নিয়োগ বিজ্ঞপ্তি',
      icon: Icons.work_outline_rounded,
      iconColor: Color(0xFF059669),
      route: Routes.jobs,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
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
      child: Column(
        children: [
          // ─── Header Pill Banner ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13.r),
                topRight: Radius.circular(13.r),
              ),
            ),
            child: Text(
              'Quick Links',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // ─── 10 Links Grid ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(8.r),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: links.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 3.3,
              ),
              itemBuilder: (context, index) {
                final link = links[index];
                return InkWell(
                  onTap: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(link.route);
                    }
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.6),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          link.icon,
                          size: 16.sp,
                          color: link.iconColor,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            link.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
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
        ],
      ),
    );
  }
}
