import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';

class HomeCoursesSection extends StatelessWidget {
  final List<HomeCourseCategoryItem> courseCategories;

  const HomeCoursesSection({
    super.key,
    required this.courseCategories,
  });

  @override
  Widget build(BuildContext context) {
    // Sample courses matching Image 3 if category list is empty
    final displayItems = courseCategories.isNotEmpty
        ? courseCategories
        : [
            HomeCourseCategoryItem(
              id: 1,
              title: 'বিসিএস প্রিলিমিনারি পূর্ণাঙ্গ কোর্স',
              slug: 'bcs-preliminary',
              coursesCount: 12,
            ),
            HomeCourseCategoryItem(
              id: 2,
              title: 'সমন্বিত ৮ ব্যাংক স্পেশাল প্রস্তুতি',
              slug: 'bank-combo',
              coursesCount: 8,
            ),
          ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: আমাদের কোর্সসমূহ + See All ────────────────────────────
          Row(
            children: [
              Text(
                'আমাদের কোর্সসমূহ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(Routes.allCourses);
                  }
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ─── Course Cards Horizontal List ──────────────────────────────────
          SizedBox(
            height: 125.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayItems.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final course = displayItems[index];
                return GestureDetector(
                  onTap: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(Routes.allCourses);
                    }
                  },
                  child: Container(
                    width: 280.w,
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Thumbnail with Category Tag
                        Stack(
                          children: [
                            Container(
                              width: 72.w,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF881337),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: course.imageUrl != null &&
                                      course.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: CachedNetworkImage(
                                        imageUrl: course.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) =>
                                            const Center(
                                          child: Icon(
                                            Icons.school_rounded,
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.school_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 4.h,
                              left: 4.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'BCS',
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 8.w),

                        // Title, Stars, Price & Action
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                course.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),

                              SizedBox(height: 2.h),

                              // Star Rating (5 Stars)
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star_rounded,
                                    size: 12.sp,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),

                              SizedBox(height: 4.h),

                              // Price + Enroll Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '৳৩৫০',
                                        style: TextStyle(
                                          fontSize: 9.5.sp,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        '৳২৯৯',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.w, vertical: 2.5.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE11D48),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    child: Text(
                                      'ভর্তি হন',
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
