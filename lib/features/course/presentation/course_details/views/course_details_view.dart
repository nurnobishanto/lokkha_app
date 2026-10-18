import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';
import '../widgets/course_button_bar.dart';
import '../widgets/course_image_viewer.dart';
import '../widgets/course_info_row.dart';
import '../widgets/course_module_expansion.dart';
import '../widgets/routine_bottom_sheet.dart';

class CourseDetailsView extends ConsumerWidget {
  final int courseId;
  const CourseDetailsView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final state = ref.watch(courseDetailsNotifierProvider(courseId));
    final notifier = ref.read(courseDetailsNotifierProvider(courseId).notifier);

    final course = state.model.course;

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
          course?.title ?? 'কোর্স বিস্তারিত',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading || course == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF006A4E)),
            );
          }
          if (state.hasError && course.id == null) {
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
                      'কোর্স বিস্তারিত লোড করা যায়নি',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () => notifier.fetchCourseDetails(courseId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('আবার চেষ্টা করুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006A4E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((course.image ?? '').isNotEmpty) ...[
                    CourseImageViewer(
                      imageUrl: Endpoints.resolveUrl(course.image),
                    ),
                    SizedBox(height: 14.h),
                  ],

                  /// Quick Info
                  CourseInfoRow(
                    title: "সাধারণ তথ্য",
                    enrolledCount: course.usersCount,
                    examCount: course.itemsCount,
                    duration: course.duration,
                    lifetimeAccess: course.lifetimeAccess == true,
                    iconColor: const Color(0xFF006A4E),
                  ),

                  if ((course.routineFile ?? '').trim().isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Text(
                      "কোর্স রুটিন",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.r),
                            ),
                          ),
                          builder: (_) => RoutineBottomSheet(
                            fileUrl: course.routineFile!,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 14.w,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: context.isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getRoutineIcon(course.routineFile!),
                              color: Colors.red.shade600,
                              size: 24.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "রুটিন দেখুন (PDF / Image)",
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14.sp,
                              color: context.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  /// Description
                  if ((course.details ?? '').trim().isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Text(
                      "কোর্স বিস্তারিত",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: state.showFullDetails
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: SizedBox(
                        height: 50.h,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: HtmlWidget(course.details!),
                        ),
                      ),
                      secondChild: HtmlWidget(course.details!),
                    ),
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: notifier.toggleDetails,
                      child: Text(
                        state.showFullDetails ? "সংক্ষেপ করুন" : "আরও দেখুন",
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF006A4E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  /// Syllabus / Exam modules
                  if ((course.modules?.isNotEmpty ?? false)) ...[
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "কোর্স সূচি / পরীক্ষা সমূহ",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "${course.modules!.length} টি বিষয়",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF006A4E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ...course.modules!.where((module) {
                      final items = module.items ?? [];
                      return items.isNotEmpty;
                    }).map((module) => CourseModuleExpansion(
                          courseId: course.id,
                          title: module.title ?? '',
                          items: module.items ?? [],
                          isEnrolled: course.isEnrolled ?? false,
                        )),
                  ],

                  /// Contact Info
                  SizedBox(height: 16.h),
                  Text(
                    "প্রয়োজনে যোগাযোগ করুন",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => makePhoneCall('+8801332804290'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: context.isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppSvgImage.asset(
                            AssetVectorPaths.phoneCall,
                            width: 17,
                            height: 17,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            '+8801332804290',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Builder(
          builder: (context) {
            if (state.isLoading || course == null) {
              return const SizedBox.shrink();
            }
            if (course.isEnrolled == true) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: 8.h,
                  left: 12.w,
                  right: 12.w,
                ),
                child: CustomActionButton(
                  height: 50,
                  text: "শেখা শুরু করুন",
                  onPressed: () {
                    final firstModule = course.modules?.isNotEmpty == true
                        ? course.modules!.first
                        : null;
                    final firstItem = firstModule?.items?.isNotEmpty == true
                        ? firstModule!.items!.first
                        : null;
                    context.pushNamed(
                      Routes.courseLearn,
                      extra: {
                        'id': course.id,
                        'item_id': firstItem?.id,
                      },
                    );
                  },
                ),
              );
            }
            return CourseBottomBar(
              title: course.title ?? '',
              price: course.salePrice.toString(),
              regularPrice: course.regularPrice?.toString() ?? '',
              courseModel: course,
            );
          },
        ),
      ),
    );
  }
}

IconData _getRoutineIcon(String filePath) {
  final lower = filePath.toLowerCase();
  if (lower.endsWith(".pdf")) return Icons.picture_as_pdf;
  if (lower.endsWith(".png") ||
      lower.endsWith(".jpg") ||
      lower.endsWith(".jpeg")) {
    return Icons.image;
  }
  return Icons.insert_drive_file;
}
