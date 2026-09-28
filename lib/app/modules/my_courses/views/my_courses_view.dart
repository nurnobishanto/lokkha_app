import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/components/custom_app_bar.dart';
import 'package:lokkha/app/services/api_call_status.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../../../../utils/constants.dart';
import '../../../routes/app_pages.dart';
import '../controllers/my_courses_controller.dart';

class MyCoursesView extends GetView<MyCoursesController> {
  const MyCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyCoursesController());
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: CustomAppBar(title: 'আমার কোর্স'),
      body: Obx(() {
        final status = controller.apiCallStatus.value;

        if (status == ApiCallStatus.loading ||
            status == ApiCallStatus.holding) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF28a745)),
          );
        }

        if (status == ApiCallStatus.error) return _buildErrorState();

        final packages = controller.model.value.packages ?? [];
        if (packages.isEmpty) return _buildEmptyState(context);

        return RefreshIndicator(
          color: const Color(0xFF28a745),
          onRefresh: controller.fetchMyCourses,
          child: GridView.builder(
            padding: EdgeInsets.all(12.r),
            itemCount: packages.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final package = packages[index];
              if (package.course == null) return const SizedBox.shrink();
              return _CourseCard(package: package);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80.r, color: context.textMuted),
          SizedBox(height: 16.h),
          Text(
            'কোনো কোর্স পাওয়া যায়নি',
            style: TextStyle(
              fontSize: 16.sp,
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 80.r, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: controller.fetchMyCourses,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28a745)),
            child: const Text('আবার চেষ্টা করুন',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final dynamic package;

  const _CourseCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final course = package.course;
    if (course == null) return const SizedBox.shrink();
    debugPrint('CourseCard Loaded with id: ${course.id.runtimeType}');
    // final bool isLifetime = (package.lifetimeAccess ?? 0) == 1;
    // final DateTime? expiry = package.accessExpiry;
    // final bool isExpired =
    //     !isLifetime && expiry != null && expiry.isBefore(DateTime.now());
    return InkWell(
      onTap: () {
              Get.toNamed(
                Routes.COURSE_DETAILS,
                arguments: {
                  'course_id': course.id,
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
              color: context.isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
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
              // --- TOP: Image Only ---
              Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: course.image != null
                            ? Image.network(
                                '${AppConstants.storageUrl}/${course.image}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _placeholderImage(),
                              )
                            : _placeholderImage(),
                      ),
                    ],
                  )),

              // --- BOTTOM: Info Section ---
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        course.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_fill,
                            size: 14.sp,
                            color: LightThemeColors.primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "কোর্সটি দেখুন",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: LightThemeColors.primaryColor,
                              fontWeight: FontWeight.w500,
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
      child:
          const Icon(Icons.school_rounded, size: 40, color: Color(0xFF28a745)),
    );
  }
}
