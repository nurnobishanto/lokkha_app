import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';

class HomeCoursesSection extends ConsumerWidget {
  final List<V1CourseModel>? courses;
  final List<HomeCourseCategoryItem> courseCategories;

  const HomeCoursesSection({
    super.key,
    this.courses,
    this.courseCategories = const [],
  });

  /// Default fallback list matching `/api/v1/courses` response
  static final List<V1CourseModel> defaultCourses = [
    const V1CourseModel(
      id: 13,
      title: 'GK Power Course – BA , IA , & Recent GK',
      slug: 'gk-power-course-ba-ia-recent-gk',
      category: CourseCategoryBrief(
        id: 9,
        title: 'University Admission  Test',
        slug: 'university-admission-test',
      ),
      imageUrl:
          'https://lokkha.com/uploads/courses/course_1789467119_B8wh2WJn.jpeg',
      duration: '120 days',
      accessDurationText: '180 Days',
      pricing: CoursePricingModel(
        regularPrice: 1000,
        salePrice: 499,
        discountAmount: 501,
        discountPercent: 50,
      ),
      stats: CourseStatsModel(
        modulesCount: 3,
        itemsCount: 1,
        enrolledStudents: 1,
        averageRating: 5,
      ),
    ),
    const V1CourseModel(
      id: 12,
      title: '১৯ তম নিবন্ধন পরীক্ষা-স্কুল পর্যায়',
      slug: '19-nibndhn-preeksha-skul-przay',
      category: CourseCategoryBrief(
        id: 5,
        title: 'NTRCA',
        slug: 'ntrca',
      ),
      imageUrl:
          'https://lokkha.com/uploads/files/shares/exam/WhatsApp Image 2026-03-29 at 4.48.16 PM.jpeg',
      duration: '120 days',
      accessDurationText: '200 Days',
      pricing: CoursePricingModel(
        regularPrice: 500,
        salePrice: 299,
        discountAmount: 201,
        discountPercent: 40,
      ),
      stats: CourseStatsModel(
        averageRating: 5,
      ),
    ),
    const V1CourseModel(
      id: 8,
      title: '১৯তম নিবন্ধন পরীক্ষা কলেজ পর্যায়',
      slug: 'ntrca-college',
      category: CourseCategoryBrief(
        id: 5,
        title: 'NTRCA',
        slug: 'ntrca',
      ),
      imageUrl:
          'https://lokkha.com/uploads/files/shares/Paid Exam/nibondon কলেজ.jpg (1).jpeg',
      accessDurationText: 'Lifetime',
      lifetimeAccess: true,
      pricing: CoursePricingModel(
        regularPrice: 500,
        salePrice: 299,
        discountAmount: 201,
        discountPercent: 40,
      ),
      stats: CourseStatsModel(
        modulesCount: 8,
        itemsCount: 22,
        enrolledStudents: 5,
        averageRating: 5,
      ),
    ),
    const V1CourseModel(
      id: 7,
      title: '৫০ তম BCS পরীক্ষা',
      slug: '50-tm-bcs-preeksha',
      category: CourseCategoryBrief(
        id: 3,
        title: 'BCS',
        slug: 'bcs',
      ),
      imageUrl:
          'https://lokkha.com/uploads/files/shares/Paid Exam/50 BCS course cover.jpg',
      pricing: CoursePricingModel(
        regularPrice: 800,
        salePrice: 400,
        discountAmount: 400,
        discountPercent: 50,
      ),
      stats: CourseStatsModel(
        modulesCount: 1,
        averageRating: 5,
      ),
    ),
    const V1CourseModel(
      id: 11,
      title: 'প্রধান শিক্ষক নিয়োগ পরীক্ষা -পূর্ণাঙ্গ মডেল টেস্ট',
      slug: 'prdhan-sikshk-niyog-preeksha-puurnango-mdel-test',
      category: CourseCategoryBrief(
        id: 4,
        title: 'Primary',
        slug: 'primary',
      ),
      imageUrl:
          'https://lokkha.com/uploads/files/shares/Paid Exam/Primary Model test course cover (1).jpg',
      duration: '120',
      accessDurationText: '120 Days',
      pricing: CoursePricingModel(
        regularPrice: 200,
        salePrice: 150,
        discountAmount: 50,
        discountPercent: 25,
      ),
      stats: CourseStatsModel(
        modulesCount: 10,
        itemsCount: 6,
        enrolledStudents: 2,
        averageRating: 5,
      ),
    ),
    const V1CourseModel(
      id: 10,
      title: 'প্রাইমারি সহকারী  শিক্ষক নিয়োগ পরীক্ষা -2',
      slug: 'praimari-shkaree-sikshk-niyog-preeksha-2',
      category: CourseCategoryBrief(
        id: 4,
        title: 'Primary',
        slug: 'primary',
      ),
      imageUrl:
          'https://lokkha.com/uploads/files/shares/Paid Exam/Primary sohokari Model test course cover.jpg',
      pricing: CoursePricingModel(
        regularPrice: 200,
        salePrice: 50,
        discountAmount: 150,
        discountPercent: 75,
      ),
      stats: CourseStatsModel(
        modulesCount: 2,
        itemsCount: 20,
        enrolledStudents: 16,
        averageRating: 5,
      ),
    ),
    const V1CourseModel(
      id: 9,
      title: 'দুর্নীতি দমন কমিশন  ও প্রতিরক্ষা মন্ত্রণালয়ের AD ও ১১০ পদ',
      slug: 'durneeti-dmn-kmisn-oo-prtirksha-mntrnalyer-ad-oo-110-pd',
      category: CourseCategoryBrief(
        id: 8,
        title: '9-10 Grade',
        slug: '9-10-grade',
      ),
      imageUrl:
          'https://lokkha.com/uploads/files/shares/exam/new_.jpg 1 (1).jpg',
      duration: '80',
      accessDurationText: '60 Days',
      pricing: CoursePricingModel(
        regularPrice: 600,
        salePrice: 200,
        discountAmount: 400,
        discountPercent: 67,
      ),
      stats: CourseStatsModel(
        modulesCount: 3,
        itemsCount: 10,
        averageRating: 5,
      ),
    ),
    const V1CourseModel(
      id: 6,
      title: 'প্রধান শিক্ষক নিয়োগ পরীক্ষা -১',
      slug: 'prdhan-sikshk-niyog-preeksha-2',
      category: CourseCategoryBrief(
        id: 4,
        title: 'Primary',
        slug: 'primary',
      ),
      imageUrl:
          'https://lokkha.com/uploads/files/shares/Paid Exam/Primary course cover (1).jpg',
      duration: '120 days',
      accessDurationText: 'Lifetime',
      lifetimeAccess: true,
      isExamBatch: true,
      pricing: CoursePricingModel(
        regularPrice: 300,
        salePrice: 150,
        discountAmount: 150,
        discountPercent: 50,
      ),
      stats: CourseStatsModel(
        modulesCount: 8,
        itemsCount: 76,
        enrolledStudents: 33,
        averageRating: 5,
        totalReviews: 1,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;

    // Responsive compact card dimensions
    final double cardWidth = isTablet
        ? (screenWidth * 0.28).clamp(185.0, 225.0)
        : (screenWidth * 0.455).clamp(158.0, 188.0);
    final double bannerHeight = (cardWidth * 0.52).clamp(80.0, 100.0);
    final double listHeight = bannerHeight + 68.h;

    final coursesState = ref.watch(coursesNotifierProvider(null));
    final List<V1CourseModel> displayCourses =
        (courses != null && courses!.isNotEmpty)
            ? courses!
            : (coursesState.courses.isNotEmpty
                ? coursesState.courses
                : defaultCourses);

    if (displayCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Section Header: আমাদের কোর্সসমূহ + সব দেখুন ──────────────────
        HomeSectionHeader(
          title: 'আমাদের কোর্সসমূহ',
          icon: Icons.play_lesson_rounded,
          seeAllText: 'সব দেখুন',
          onSeeAll: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.courses);
            }
          },
        ),
        SizedBox(height: 4.h),

        // ─── Compact & Responsive Horizontal All Courses List ──────────────
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: displayCourses.length,
            separatorBuilder: (_, __) => SizedBox(width: 9.w),
            itemBuilder: (context, index) {
              final course = displayCourses[index];
              return _HomePremiumCourseCard(
                course: course,
                isDark: isDark,
                cardWidth: cardWidth,
                bannerHeight: bannerHeight,
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
    );
  }
}

class _HomePremiumCourseCard extends StatelessWidget {
  final V1CourseModel course;
  final bool isDark;
  final double cardWidth;
  final double bannerHeight;
  final VoidCallback onTap;

  const _HomePremiumCourseCard({
    required this.course,
    required this.isDark,
    required this.cardWidth,
    required this.bannerHeight,
    required this.onTap,
  });

  String _resolveDurationLabel() {
    if (course.lifetimeAccess ||
        (course.accessDurationText?.toLowerCase() == 'lifetime')) {
      return 'Lifetime';
    }
    if (course.accessDurationText != null &&
        course.accessDurationText!.trim().isNotEmpty) {
      return course.accessDurationText!.trim();
    }
    if (course.duration != null && course.duration!.trim().isNotEmpty) {
      final d = course.duration!.trim();
      return d.toLowerCase().contains('day') ? d : '$d Days';
    }
    return 'Full Access';
  }

  @override
  Widget build(BuildContext context) {
    final categoryTitle = (course.category?.title.trim().isNotEmpty == true)
        ? course.category!.title.trim()
        : 'প্রিমিয়াম';
    final int discountPct = course.pricing.discountPercent;
    final bool hasDiscount = course.hasDiscount;
    final String durationLabel = _resolveDurationLabel();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.3 : 0.05,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. Compact Top Banner + Category & Discount Badges ──────
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(11.r)),
                child: SizedBox(
                  height: bannerHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (course.imageUrl != null &&
                          course.imageUrl!.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: course.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _buildFallbackBanner(),
                        )
                      else
                        _buildFallbackBanner(),

                      // Subtle bottom gradient for badge contrast
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 28.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Top-left Category Badge
                      Positioned(
                        top: 5.h,
                        left: 5.w,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: cardWidth * 0.56),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              categoryTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Top-right Discount Badge
                      if (discountPct > 0)
                        Positioned(
                          top: 5.h,
                          right: 5.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE11D48),
                                  Color(0xFFF97316),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              '-$discountPct%',
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),

                      // Bottom-right Rating + Duration Pill on Banner
                      Positioned(
                        bottom: 4.h,
                        left: 5.w,
                        right: 5.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 1.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 9.5.sp,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(width: 2.5.w),
                                    Flexible(
                                      child: Text(
                                        durationLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 8.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.5.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: const Color(0xFFFBBF24),
                                    size: 10.5.sp,
                                  ),
                                  SizedBox(width: 1.5.w),
                                  Text(
                                    course.displayRating,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── 2. Compact Title + Price & Enroll Row ───────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(7.w, 5.h, 7.w, 5.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title (Fixed 2-line height for uniform alignment, no middle gap)
                      SizedBox(
                        height: 30.h,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.cardTitle.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Responsive Price & Action Button Row
                      Row(
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
                                  Text(
                                    '৳${course.displaySalePrice}',
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF006A4E),
                                      height: 1.1,
                                    ),
                                  ),
                                  if (hasDiscount) ...[
                                    SizedBox(width: 3.5.w),
                                    Text(
                                      '৳${course.displayRegularPrice}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF94A3B8),
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF006A4E),
                                  Color(0xFF059669),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  course.isEnrolled ? 'চালিয়ে যান' : 'ভর্তি হন',
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 10.sp,
                                  color: Colors.white,
                                ),
                              ],
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

  Widget _buildFallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF006A4E), Color(0xFF0F172A)],
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
