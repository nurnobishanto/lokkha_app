import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/presentation/exam_category/widgets/exam_category_card.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';

class HomeCategoriesSection extends StatefulWidget {
  final List<HomeExamCategoryItem> examCategories;
  final List<HomeCourseCategoryItem> courseCategories;

  const HomeCategoriesSection({
    super.key,
    required this.examCategories,
    required this.courseCategories,
  });

  static final List<HomeCourseCategoryItem> defaultCourseCategories = [
    HomeCourseCategoryItem(
      id: 3,
      title: "BCS",
      slug: "bcs",
      coursesCount: 1,
      theme: HomeThemeConfig(icon: "ri-graduation-cap-fill"),
    ),
    HomeCourseCategoryItem(
      id: 4,
      title: "Primary",
      slug: "primary",
      coursesCount: 3,
      theme: HomeThemeConfig(icon: "ri-book-open-fill"),
    ),
    HomeCourseCategoryItem(
      id: 5,
      title: "NTRCA",
      slug: "ntrca",
      coursesCount: 2,
      theme: HomeThemeConfig(icon: "ri-award-fill"),
    ),
    HomeCourseCategoryItem(
      id: 6,
      title: "Bank Preperation",
      slug: "bank-preperation",
      coursesCount: 0,
      theme: HomeThemeConfig(icon: "ri-medal-fill"),
    ),
    HomeCourseCategoryItem(
      id: 7,
      title: "11-20 Grade",
      slug: "11-20-grade",
      coursesCount: 0,
      theme: HomeThemeConfig(icon: "ri-shield-star-fill"),
    ),
    HomeCourseCategoryItem(
      id: 8,
      title: "9-10 Grade",
      slug: "9-10-grade",
      coursesCount: 1,
      theme: HomeThemeConfig(icon: "ri-briefcase-4-fill"),
    ),
    HomeCourseCategoryItem(
      id: 9,
      title: "University Admission  Test",
      slug: "university-admission-test",
      coursesCount: 1,
      theme: HomeThemeConfig(icon: "ri-trophy-fill"),
    ),
  ];

  static final List<HomeExamCategoryItem> defaultExamCategories = [
    HomeExamCategoryItem(
      id: 45,
      name: "১৯ তম শিক্ষক নিবন্ধন  ( স্কুল ও কলেজ)",
      slug: "ntrca-nibndhn-skul-oo-klej",
      examsCount: 92,
      theme: HomeThemeConfig(icon: "ri-graduation-cap-fill"),
    ),
    HomeExamCategoryItem(
      id: 46,
      name: "৫১ তম BCS",
      slug: "51-bcs",
      examsCount: 41,
      theme: HomeThemeConfig(icon: "ri-book-open-fill"),
    ),
    HomeExamCategoryItem(
      id: 47,
      name: "Bank Preparation",
      slug: "bank-preparation",
      examsCount: 87,
      theme: HomeThemeConfig(icon: "ri-award-fill"),
    ),
    HomeExamCategoryItem(
      id: 48,
      name: "প্রাইমারি  শিক্ষক নিয়োগ",
      slug: "praimari",
      examsCount: 96,
      theme: HomeThemeConfig(icon: "ri-medal-fill"),
    ),
    HomeExamCategoryItem(
      id: 49,
      name: "৫০ তম  BCS",
      slug: "47-bcs",
      examsCount: 50,
      theme: HomeThemeConfig(icon: "ri-shield-star-fill"),
    ),
    HomeExamCategoryItem(
      id: 52,
      name: "সাম্প্রতিক  বিষয়াবলীর উপর পরীক্ষা",
      slug: "smprti-bishyableer-upr-preeksha",
      examsCount: 69,
      theme: HomeThemeConfig(icon: "ri-briefcase-4-fill"),
    ),
    HomeExamCategoryItem(
      id: 54,
      name: "9-10 Grade",
      slug: "9-10-grade",
      examsCount: 10,
      theme: HomeThemeConfig(icon: "ri-trophy-fill"),
    ),
    HomeExamCategoryItem(
      id: 57,
      name: "11-20 Grade",
      slug: "11-20-grade",
      examsCount: 82,
      theme: HomeThemeConfig(icon: "ri-lightbulb-fill"),
    ),
    HomeExamCategoryItem(
      id: 58,
      name: "University Admission",
      slug: "university-admission",
      examsCount: 2,
      theme: HomeThemeConfig(icon: "ri-graduation-cap-fill"),
    ),
  ];

  static IconData getThemeIcon(String? iconKey) {
    switch (iconKey) {
      case 'ri-graduation-cap-fill':
        return Icons.school_rounded;
      case 'ri-book-open-fill':
        return Icons.auto_stories_rounded;
      case 'ri-award-fill':
        return Icons.military_tech_rounded;
      case 'ri-medal-fill':
        return Icons.workspace_premium_rounded;
      case 'ri-shield-star-fill':
        return Icons.verified_user_rounded;
      case 'ri-briefcase-4-fill':
        return Icons.work_outline_rounded;
      case 'ri-trophy-fill':
        return Icons.emoji_events_rounded;
      case 'ri-lightbulb-fill':
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  State<HomeCategoriesSection> createState() => _HomeCategoriesSectionState();
}

class _HomeCategoriesSectionState extends State<HomeCategoriesSection> {
  bool _isExamsExpanded = false;
  bool _isCoursesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final effectiveExams = widget.examCategories.isNotEmpty
        ? widget.examCategories
        : HomeCategoriesSection.defaultExamCategories;
    final effectiveCourses = widget.courseCategories.isNotEmpty
        ? widget.courseCategories
        : HomeCategoriesSection.defaultCourseCategories;

    final displayedExams = _isExamsExpanded
        ? effectiveExams
        : effectiveExams.take(4).toList();

    final displayedCourses = _isCoursesExpanded
        ? effectiveCourses
        : effectiveCourses.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 1. Free Exam Categories (ফ্রি পরীক্ষা সমূহ) ────────────────────
        if (effectiveExams.isNotEmpty) ...[
          HomeSectionHeader(
            title: 'ফ্রি পরীক্ষা সমূহ',
            icon: Icons.menu_book_rounded,
            seeAllText: _isExamsExpanded ? 'কম দেখুন' : 'সব দেখুন',
            onSeeAll: () {
              setState(() {
                _isExamsExpanded = !_isExamsExpanded;
              });
            },
          ),
          SizedBox(height: 6.h),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: displayedExams.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
                childAspectRatio: 2.95,
              ),
              itemBuilder: (context, index) {
                final cat = displayedExams[index];
                return ExamCategoryCard(
                  title: cat.name,
                  slug: cat.slug,
                  imageUrl: cat.imageUrl,
                  themeIcon: cat.theme?.icon,
                  isPremium: false,
                  onTap: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(
                        Routes.examCategoryDetails,
                        extra: {
                          'category_id': cat.id,
                          'category_name': cat.name,
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
        ],

        // ─── 2. Premium Exam Categories (প্রিমিয়াম পরীক্ষা সমূহ) ─────────
        if (effectiveCourses.isNotEmpty) ...[
          HomeSectionHeader(
            title: 'প্রিমিয়াম পরীক্ষা সমূহ',
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFFD97706),
            iconBackgroundColor: const Color(0xFFFEF3C7),
            trailingBadge: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF9F1C),
                    Color(0xFFF77F00),
                  ],
                ),
                borderRadius: BorderRadius.circular(6.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF77F00).withValues(alpha: 0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 10.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            seeAllText: _isCoursesExpanded ? 'কম দেখুন' : 'সব দেখুন',
            onSeeAll: () {
              setState(() {
                _isCoursesExpanded = !_isCoursesExpanded;
              });
            },
          ),
          SizedBox(height: 6.h),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: displayedCourses.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
                childAspectRatio: 2.95,
              ),
              itemBuilder: (context, index) {
                final courseCat = displayedCourses[index];
                return ExamCategoryCard(
                  title: courseCat.title,
                  slug: courseCat.slug,
                  imageUrl: courseCat.imageUrl,
                  themeIcon: courseCat.theme?.icon,
                  isPremium: true,
                  onTap: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(
                        Routes.courses,
                        extra: {
                          'course_category_id': courseCat.id,
                          'title': courseCat.title,
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
