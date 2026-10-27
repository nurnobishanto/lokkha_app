import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';
import 'package:lokkha/features/profile/presentation/profile/riverpod/profile_notifier.dart';
import '../widgets/course_button_bar.dart';
import '../widgets/course_image_viewer.dart';
import '../widgets/course_info_row.dart';
import '../widgets/course_module_expansion.dart';
import '../widgets/routine_bottom_sheet.dart';

class CourseDetailsView extends ConsumerStatefulWidget {
  final int courseId;
  final bool? initialIsEnrolled;

  const CourseDetailsView({
    super.key,
    required this.courseId,
    this.initialIsEnrolled,
  });

  @override
  ConsumerState<CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends ConsumerState<CourseDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(courseDetailsNotifierProvider(widget.courseId).notifier)
          .fetchCourseDetails(widget.courseId);
      ref
          .read(myCoursesNotifierProvider.notifier)
          .fetchMyCourses(isRefresh: true);
      ref.read(profileNotifierProvider.notifier).fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final state = ref.watch(courseDetailsNotifierProvider(widget.courseId));
    final notifier = ref.read(courseDetailsNotifierProvider(widget.courseId).notifier);
    final myCoursesState = ref.watch(myCoursesNotifierProvider);

    final course = state.model.course;

    // The live API response for this course is the authoritative source of truth.
    final bool isUserEnrolled;
    if (course != null && course.isEnrolled != null) {
      // If the API explicitly returns true or false, strictly respect the server's verdict.
      isUserEnrolled = course.isEnrolled == true;
    } else if (course != null) {
      // Fallback only if the backend did not return any enrollment/user_access field
      isUserEnrolled = myCoursesState.model.courses.any(
              (c) => c.courseId == widget.courseId && !c.isExpired) ||
          havePackage.value;
    } else {
      // Preliminary hint while network request is loading
      isUserEnrolled = widget.initialIsEnrolled == true;
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
      body: RefreshIndicator(
        color: const Color(0xFF006A4E),
        onRefresh: () async {
          await Future.wait<dynamic>([
            notifier.fetchCourseDetails(widget.courseId),
            ref.read(myCoursesNotifierProvider.notifier).fetchMyCourses(isRefresh: true),
            ref.read(profileNotifierProvider.notifier).fetchProfileData(),
          ]);
        },
        child: Builder(
          builder: (context) {
            if (state.isLoading || course == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200.h),
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF006A4E)),
                  ),
                ],
              );
            }
            if (state.hasError && course.id == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 150.h),
                  Padding(
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
                          onPressed: () => notifier.fetchCourseDetails(widget.courseId),
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
                ],
              );
            }
            return SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                  if (isUserEnrolled) ...[
                    _buildEnrolledProgressCard(course, context),
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
                          isEnrolled: isUserEnrolled,
                        )),
                  ],

                  /// Community & Live Class Links
                  if (isUserEnrolled) ...[
                    _buildCommunityLinksCard(course, context),
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
    ),
    bottomNavigationBar: SafeArea(
        child: Builder(
          builder: (context) {
            if (state.isLoading || course == null) {
              return const SizedBox.shrink();
            }
            if (isUserEnrolled) {
              final bool hasProgress =
                  (course.progressPercent != null && course.progressPercent! > 0) ||
                      course.resumeItemId != null;
              final buttonLabel = hasProgress ? "পড়া চালিয়ে যান" : "শেখা শুরু করুন";

              return Padding(
                padding: EdgeInsets.only(
                  bottom: 8.h,
                  left: 12.w,
                  right: 12.w,
                ),
                child: CustomActionButton(
                  height: 50,
                  text: buttonLabel,
                  onPressed: () {
                    final firstModule = course.modules?.isNotEmpty == true
                        ? course.modules!.first
                        : null;
                    final firstItem = firstModule?.items?.isNotEmpty == true
                        ? firstModule!.items!.first
                        : null;
                    final targetItemId = course.resumeItemId ?? firstItem?.id;

                    context.pushNamed(
                      Routes.courseLearn,
                      extra: {
                        'id': course.id,
                        'item_id': targetItemId,
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

  Widget _buildEnrolledProgressCard(Course course, BuildContext context) {
    final progress = (course.progressPercent ?? 0).toInt();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006A4E),
            Color(0xFF004D38),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006A4E).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'আপনার এনরোলমেন্ট সক্রিয়',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  course.lifetimeAccess == true
                      ? 'লাইফটাইম'
                      : (course.daysRemaining != null
                          ? '${course.daysRemaining} দিন বাকি'
                          : 'অ্যাক্টিভ'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'কোর্স অগ্রগতি',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12.sp,
                ),
              ),
              Text(
                '$progress% সম্পন্ন',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: (progress.clamp(0, 100)) / 100.0,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityLinksCard(Course course, BuildContext context) {
    final bool hasCommunity = (course.facebookGroup?.toString().isNotEmpty ?? false) ||
        (course.whatsappGroupLink?.toString().isNotEmpty ?? false) ||
        (course.meetLink?.toString().isNotEmpty ?? false) ||
        (course.zoomLink?.toString().isNotEmpty ?? false) ||
        (course.telegramGroup?.toString().isNotEmpty ?? false);

    if (!hasCommunity) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text(
          "কমিউনিটি ও ক্লাস লিংক",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            if ((course.facebookGroup?.toString() ?? '').isNotEmpty)
              _buildCommunityBtn(
                title: 'ফেসবুক গ্রুপ',
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                url: course.facebookGroup.toString(),
              ),
            if ((course.whatsappGroupLink?.toString() ?? '').isNotEmpty)
              _buildCommunityBtn(
                title: 'হোয়াটসঅ্যাপ',
                icon: Icons.chat_rounded,
                color: const Color(0xFF25D366),
                url: course.whatsappGroupLink.toString(),
              ),
            if ((course.meetLink?.toString() ?? '').isNotEmpty)
              _buildCommunityBtn(
                title: 'লাইভ ক্লাস (Meet)',
                icon: Icons.video_call_rounded,
                color: const Color(0xFF00897B),
                url: course.meetLink.toString(),
              ),
            if ((course.zoomLink?.toString() ?? '').isNotEmpty)
              _buildCommunityBtn(
                title: 'লাইভ ক্লাস (Zoom)',
                icon: Icons.videocam_rounded,
                color: const Color(0xFF2D8CFF),
                url: course.zoomLink.toString(),
              ),
            if ((course.telegramGroup?.toString() ?? '').isNotEmpty)
              _buildCommunityBtn(
                title: 'টেলিগ্রাম',
                icon: Icons.send_rounded,
                color: const Color(0xFF0088CC),
                url: course.telegramGroup.toString(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunityBtn({
    required String title,
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => launchUrlString(url, mode: LaunchMode.externalApplication),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
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
