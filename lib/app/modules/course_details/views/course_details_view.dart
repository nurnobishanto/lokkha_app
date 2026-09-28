import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import 'package:lokkha/utils/constants.dart';
import '../../../../utils/phone_utils.dart';
import '../../../components/custom_action_button.dart';
import '../../../routes/app_pages.dart';
import '../controllers/course_details_controller.dart';
import '../widgets/course_button_bar.dart';
import '../widgets/course_image_viewer.dart';
import '../widgets/course_info_row.dart';
import '../widgets/course_module_expansion.dart';
import '../widgets/routine_bottom_sheet.dart';

class CourseDetailsView extends GetView<CourseDetailsController> {
  const CourseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GetBuilder<CourseDetailsController>(
          builder: (controller) {
            return AppBar(
              backgroundColor: LightThemeColors.primaryColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                controller.model.course?.title ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 15.5),
              ),
            );
          },
        ),
      ),
      body: GetBuilder<CourseDetailsController>(
        init: CourseDetailsController(),
        builder: (controller) {
          final course = controller.model.course;
          if (controller.isLoading || course == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  if ((course.image ?? '').isNotEmpty) ...[
                    CourseImageViewer(
                        imageUrl: AppConstants.storageUrl + course.image!),
                    const SizedBox(height: 20),
                  ],

                  /// Quick Info
                  CourseInfoRow(
                    title: "Quick Info",
                    enrolledCount: course.usersCount,
                    examCount: course.itemsCount,
                    duration: course.duration,
                    lifetimeAccess: course.lifetimeAccess == true,
                    iconColor: theme.primaryColor,
                  ),

                  if ((course.routineFile ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      "Routine",
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold, color: context.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => RoutineBottomSheet(
                            fileUrl: course.routineFile!,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getRoutineIcon(course.routineFile!),
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text("View Routine", style: textTheme.bodyMedium?.copyWith(color: context.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // const SizedBox(height: 10),
                  // if (course.package != null && !havePackage.value) ...[
                  //   FreePackageAddon(
                  //     packageTitle: course.package?.name ?? '',
                  //     onTap: () {
                  //       Get.to(const AllPackages());
                  //     },
                  //   ),
                  // ],

                  /// Instructor
                  // if (course.teachers?.isNotEmpty ?? false) ...[
                  //   const SizedBox(height: 15),
                  //   Text(
                  //     "Course Instructor",
                  //     style: textTheme.titleMedium
                  //         ?.copyWith(fontWeight: FontWeight.bold),
                  //   ),
                  //   ...course.teachers!.map((teacher) => InstructorCard(
                  //         name: teacher.name ?? '',
                  //         imageUrl:
                  //             AppConstants.storageUrl + (teacher.image ?? '') ,
                  //         //tagline: teacher.tagline,
                  //         tagline: "",
                  //         experience: "${teacher.experience} years Experience",
                  //       )),
                  // ],

                  /// Description
                  if ((course.details ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      "Course Details",
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Obx(() => AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: controller.showFullDetails.value
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: SizedBox(
                            height: 30, // Approx. 2–3 lines
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: HtmlWidget(course.details!),
                            ),
                          ),
                          secondChild: HtmlWidget(course.details!),
                        )),
                    GestureDetector(
                      onTap: controller.toggleDetails,
                      child: Obx(() => Text(
                            controller.showFullDetails.value
                                ? " See Less"
                                : " See More",
                            style: textTheme.bodyMedium?.copyWith(
                              color: LightThemeColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ],

                  /// Syllabus
                  if ((course.modules?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Course Module",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...course.modules!.where((module) {
                      final items = module.items ?? [];
                      return items.any((item) =>
                          item.youtubeVideo != null ||
                          item.video != null ||
                          item.pdf != null ||
                          item.image != null ||
                          item.file != null ||
                          item.details != null ||
                          item.url != null);
                    }).map((module) => CourseModuleExpansion(
                          title: module.title ?? '',
                          items: module.items ?? [],
                          isEnrolled: course.isEnrolled ?? false,
                        ))
                  ],

                  /// Contact Info
                  const SizedBox(height: 10),
                  Text(
                    "Call For More Details",
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => makePhoneCall('+8801332804290'),
                    child: Row(
                      children: [
                        Image.asset('assets/images/phone_call.png',
                            width: 17, height: 17),
                        const SizedBox(width: 10),
                        const Text('+8801332804290',
                            style: TextStyle(fontSize: 14.0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: GetBuilder<CourseDetailsController>(
          init: CourseDetailsController(),
          builder: (controller) {
            final course = controller.model.course;
            if (controller.isLoading || course == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.model.course?.isEnrolled == true) {
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                child: CustomActionButton(
                  height: 50,
                  text: "Start Learning",
                  onPressed: () {
                    Get.toNamed(Routes.COURSE_LEARN,
                        arguments: {'id': controller.model.course!.id, 'item_id': controller.model.course?.modules?.first.items?.first.id});
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
  return Icons.insert_drive_file; // fallback
}
