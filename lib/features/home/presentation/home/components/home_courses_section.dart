import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';

class HomeCoursesSection extends ConsumerWidget {
  final List<V1CourseModel>? courses;
  final List<HomeCourseCategoryItem> courseCategories;

  const HomeCoursesSection({
    super.key,
    this.courses,
    this.courseCategories = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;

    final double cardWidth = isTablet
        ? (screenWidth * 0.48).clamp(300.0, 380.0)
        : (screenWidth * 0.84).clamp(278.0, 336.0);

    final coursesState = ref.watch(coursesNotifierProvider(null));

    // Resolve 100% dynamic courses from API (or injected courses parameter)
    final List<V1CourseModel> displayCourses =
        (courses != null && courses!.isNotEmpty)
            ? courses!
            : coursesState.courses;

    // Show skeleton loader while initial API call is in progress
    if (coursesState.isLoading && displayCourses.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 8.h),
            _buildSkeletonList(isDark: isDark, cardWidth: cardWidth),
          ],
        ),
      );
    }

    if (displayCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: আমাদের কোর্সসমূহ + See All ────────────────────────────
          _buildHeader(context),

        5.horizontalSpace,

          // ─── Dynamic Horizontal Course Cards List (From API) ───────────────
          SizedBox(
            height: 132.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: displayCourses.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final course = displayCourses[index];
                return _HomeHorizontalCourseCard(
                  course: course,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  onTap: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(
                        Routes.courseDetails,
                        extra: {
                          'course_id': course.id,
                          'is_enrolled': course.isEnrolled,
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'আমাদের কোর্সসমূহ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.sectionTitle,
          ),
        ),
        InkWell(
          onTap: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.courses);
            }
          },
          borderRadius: BorderRadius.circular(6.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Text(
              'See All',
              style: context.chipText.copyWith(
                color: const Color(0xFF2A8D6F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList({
    required bool isDark,
    required double cardWidth,
  }) {
    final shimmerColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    return SizedBox(
      height: 132.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, __) {
          return Container(
            width: cardWidth,
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: shimmerColor, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 100.w,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 14.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Container(
                        height: 18.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      Container(
                        height: 12.h,
                        width: 90.w,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 16.h,
                            width: 70.w,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Container(
                            height: 24.h,
                            width: 76.w,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeHorizontalCourseCard extends StatelessWidget {
  final V1CourseModel course;
  final bool isDark;
  final double cardWidth;
  final VoidCallback onTap;

  const _HomeHorizontalCourseCard({
    required this.course,
    required this.isDark,
    required this.cardWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String categoryTitle =
        (course.category?.title.trim().isNotEmpty == true)
            ? course.category!.title.trim()
            : 'প্রিমিয়াম';
    final bool hasDiscount = course.hasDiscount;
    final int filledStars = course.stats.averageRating > 0
        ? course.stats.averageRating.round().clamp(1, 5)
        : 4;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: cardWidth,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFF1F5F9),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.32 : 0.06,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.15 : 0.02,
                ),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── 1. Left Course Thumbnail ──────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 100.w,
                  height: double.infinity,
                  child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            child: const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _buildFallbackThumb(),
                        )
                      : _buildFallbackThumb(),
                ),
              ),

              SizedBox(width: 12.w),

              // ─── 2. Right Details Column ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Course Title (1 line, crisp bold)
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.cardTitle.copyWith(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                        height: 1.2,
                      ),
                    ),

                    // Category Pill Badge (Green rounded pill)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 2.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A8D6F),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        categoryTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                          height: 1.15,
                        ),
                      ),
                    ),

                    // 5-Star Rating Row (4 filled + 1 outlined or based on rating)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) {
                        final isFilled = i < filledStars;
                        return Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 14.5.sp,
                            color: const Color(0xFFF59E0B),
                          ),
                        );
                      }),
                    ),

                    // Bottom Row: Strikethrough + Sale Price & Red "কোর্সটি কিনুন" Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                if (hasDiscount) ...[
                                  Text(
                                    '৳${course.displayRegularPrice}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w500,
                                      height: 1.1,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                ],
                                Text(
                                  '৳${course.displaySalePrice}',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: context.textPrimary,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC3545),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'কোর্সটি কিনুন',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
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
      ),
    );
  }

  Widget _buildFallbackThumb() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF881337), Color(0xFF4C0519)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.school_rounded,
          size: 28.sp,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
