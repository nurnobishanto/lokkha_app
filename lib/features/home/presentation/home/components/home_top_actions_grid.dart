import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/widgets/app_svg_image.dart';

class HomeTopActionsGrid extends StatelessWidget {
  const HomeTopActionsGrid({super.key});

  static final List<({
    String title,
    String vectorPath,
    String route,
  })> items = [
    (
      title: 'Vocabulary Game',
      vectorPath: AssetVectorPaths.icVocabulary,
      route: Routes.vocabulary,
    ),
    (
      title: 'GK',
      vectorPath: AssetVectorPaths.icGk,
      route: Routes.currentAffairs,
    ),
    (
      title: 'কুইক প্র্যাকটিস',
      vectorPath: AssetVectorPaths.icQuickPractice,
      route: Routes.mockTestTab,
    ),
    (
      title: 'ভিডিও ক্লাস',
      vectorPath: AssetVectorPaths.icVideoClass,
      route: Routes.courses,
    ),
    (
      title: 'জনপ্রিয় প্রশ্নব্যাংক',
      vectorPath: AssetVectorPaths.icQuestionBank,
      route: Routes.questionBank,
    ),
    (
      title: 'চাকরি ও ক্যারিয়ার',
      vectorPath: AssetVectorPaths.icCareerUpdates,
      route: Routes.jobs,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 2.85,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () {
              if (GoRouter.maybeOf(context) != null) {
                context.push(item.route);
              }
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: context.isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDark ? 0.35 : 0.06,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDark ? 0.2 : 0.02,
                    ),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AppSvgImage.asset(
                    item.vectorPath,
                    width: 24.r,
                    height: 24.r,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item.title,
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
          );
        },
      ),
    );
  }
}
