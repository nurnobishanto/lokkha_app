import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/features/course/data/models/my_course_model.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';

class MyCoursesView extends ConsumerStatefulWidget {
  const MyCoursesView({super.key});

  @override
  ConsumerState<MyCoursesView> createState() => _MyCoursesViewState();
}

class _MyCoursesViewState extends ConsumerState<MyCoursesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myCoursesNotifierProvider.notifier).fetchMyCourses(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myCoursesNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myCoursesNotifierProvider);
    final notifier = ref.read(myCoursesNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(title: 'আমার কোর্স'),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: LightThemeColors.primaryColor,
              ),
            );
          }

          if (state.hasError && state.model.courses.isEmpty) {
            return _buildErrorState(notifier, state.errorMessage);
          }

          final courses = state.model.courses;
          if (courses.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            color: LightThemeColors.primaryColor,
            onRefresh: () => notifier.fetchMyCourses(isRefresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(12.r),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.84,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _CourseCard(course: courses[index]);
                      },
                      childCount: courses.length,
                    ),
                  ),
                ),
                if (state.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: LightThemeColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: LightThemeColors.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 72.r,
                color: LightThemeColors.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'কোনো কোর্স পাওয়া যায়নি',
              style: TextStyle(
                fontSize: 17.sp,
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'আপনি এখনো কোনো কোর্সে ভর্তি হননি। নতুন কোর্স দেখে এখনই প্রস্তুতি শুরু করুন!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: context.textMuted,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => context.push(Routes.courses),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('কোর্সগুলো দেখুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: LightThemeColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(MyCoursesNotifier notifier, String? message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64.r,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              message ?? 'সার্ভার সংযোগে সমস্যা হয়েছে',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => notifier.fetchMyCourses(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('আবার চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: LightThemeColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final EnrolledCourseItem course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () {
        context.pushNamed(
          Routes.courseDetails,
          extra: {
            'course_id': course.courseId,
            'is_enrolled': true,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: context.isDark
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOP: Image with Validity Badge ---
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (course.resolvedImageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: course.resolvedImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholderImage(),
                        errorWidget: (_, __, ___) => _placeholderImage(),
                      )
                    else
                      _placeholderImage(),

                    // Lifetime or Expiration Status Badge
                    if (course.lifetimeAccess)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: LightThemeColors.primaryColor,
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.all_inclusive_rounded,
                                size: 10.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'লাইফটাইম',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (course.isExpired)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'মেয়াদ শেষ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else if (course.remainingDays != null)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: course.isExpiringSoon
                                ? Colors.orange.shade800
                                : const Color(0xB3000000),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '${course.remainingDays} দিন বাকি',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // --- BOTTOM: Info Section ---
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            course.isExpired
                                ? Icons.info_outline_rounded
                                : Icons.play_circle_fill,
                            size: 14.sp,
                            color: course.isExpired
                                ? Colors.grey
                                : LightThemeColors.primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              course.isExpired ? "বিস্তারিত দেখুন" : "কোর্সটি দেখুন",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: course.isExpired
                                    ? Colors.grey
                                    : LightThemeColors.primaryColor,
                                fontWeight: FontWeight.w600,
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

  Widget _placeholderImage() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(
          Icons.school_rounded,
          size: 36,
          color: LightThemeColors.primaryColor,
        ),
      ),
    );
  }
}
