import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';
import '../widgets/custom_course_card.dart';

class CoursesView extends ConsumerStatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const CoursesView({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends ConsumerState<CoursesView> {
  int? _activeCategoryId;

  @override
  void initState() {
    super.initState();
    _activeCategoryId = widget.categoryId;
  }

  @override
  void didUpdateWidget(CoursesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      setState(() {
        _activeCategoryId = widget.categoryId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coursesNotifierProvider(_activeCategoryId));
    final notifier = ref.read(coursesNotifierProvider(_activeCategoryId).notifier);

    // Compute title
    String appTitle = 'কোর্সসমূহ';
    if (_activeCategoryId != null) {
      if (widget.categoryName != null && widget.categoryName!.trim().isNotEmpty) {
        appTitle = widget.categoryName!;
      } else {
        final found = state.categories.where((c) => c.id == _activeCategoryId);
        if (found.isNotEmpty) {
          appTitle = found.first.title;
        }
      }
    }

    return Scaffold(
      backgroundColor: context.isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(Routes.home);
            }
          },
        ),
        title: Text(
          appTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            notifier.fetchCourses(_activeCategoryId, refresh: true),
            ref.read(myCoursesNotifierProvider.notifier).fetchMyCourses(isRefresh: true),
          ]);
        },
        color: const Color(0xFF006A4E),
        child: _buildBody(context, state, notifier),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CoursesState state,
    CoursesNotifier notifier,
  ) {
    // 1. Loading State (initial)
    if (state.isLoading && state.courses.isEmpty && (state.model.courses?.data == null || state.model.courses!.data!.isEmpty)) {
      return _buildSkeletonGrid();
    }

    // 2. Error State
    if (state.hasError && state.courses.isEmpty && (state.model.courses?.data == null || state.model.courses!.data!.isEmpty)) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 52.sp,
                color: context.textMuted,
              ),
              SizedBox(height: 12.h),
              Text(
                state.errorMessage ?? 'কোর্স লোড করা যায়নি',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => notifier.fetchCourses(_activeCategoryId, refresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Extract items (V1 priority, legacy fallback)
    final courses = state.courses;
    final legacyCourses = state.model.courses?.data ?? [];
    final itemCount = courses.isNotEmpty ? courses.length : legacyCourses.length;

    // 4. Empty State
    if (itemCount == 0) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 56.sp,
                  color: context.textMuted.withValues(alpha: 0.6),
                ),
                SizedBox(height: 14.h),
                Text(
                  'কোনো কোর্স পাওয়া যায়নি',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'অন্যান্য ক্যাটাগরিগুলো দেখুন',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 5. Courses Grid View (2 Columns)
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        if (courses.isNotEmpty) {
          final course = courses[index];
          return CustomCourseCard(
            imageUrl: course.imageUrl ?? '',
            title: course.title,
            regularPrice: course.displayRegularPrice,
            salePrice: course.displaySalePrice,
            rating: course.displayRating,
            duration: course.duration,
            enrolledCount: course.stats.enrolledStudents,
            onPressed: () {
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
        } else {
          final legacy = legacyCourses[index];
          return CustomCourseCard(
            imageUrl: Endpoints.resolveUrl(legacy.image),
            title: legacy.title ?? '',
            regularPrice: legacy.regularPrice?.toString() ?? '0',
            salePrice: legacy.salePrice?.toString() ?? '0',
            rating: '5',
            duration: legacy.duration,
            enrolledCount: legacy.usersCount,
            onPressed: () {
              if (GoRouter.maybeOf(context) != null) {
                context.push(
                  Routes.courseDetails,
                  extra: {
                    'course_id': legacy.id,
                    'is_enrolled': legacy.isEnrolled,
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: context.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: Container(
                  height: 100.h,
                  color: context.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        color: context.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      height: 12.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: context.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
