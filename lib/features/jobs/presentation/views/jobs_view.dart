import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/utils/date_formatter.dart';
import 'package:lokkha/routes/routes.dart';
import '../controllers/jobs_controller.dart';

class JobsView extends GetView<JobsController> {
  const JobsView({super.key});
  @override
  Widget build(BuildContext context) {
    final JobsController controller = Get.put(JobsController());
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "সর্বশেষ নিয়োগ বিজ্ঞপ্তি",
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                return Padding(
                  padding: const EdgeInsets.all(8.00),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CustomSearchBar(
                      //   prefixIcon: Icons.search,
                      //   onChanged: (value) {
                      //     controller.search.value = value.toString();
                      //     controller.getGovJobs(value.toString());
                      //     if (kDebugMode) {
                      //       print("Search JOBs ${value.toString()}");
                      //     }
                      //   },
                      // ),

                      controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          // Expanded(
                          //         child: ListView.builder(
                          //           itemCount: 6,
                          //           itemBuilder: (_, index) =>
                          //               const ShimmerPlaceholder(),
                          //         ),
                          //       )
                          : controller.model.value.jobs!.data!.isEmpty
                              ? const Center(
                                  child: Text('তথ্য পাওয়া যায়নি'),
                                )
                              : Expanded(
                                  child: ListView.separated(
                                    itemCount: controller
                                            .model.value.jobs!.data!.length +
                                        1,
                                    shrinkWrap: true,
                                    itemBuilder: (_, index) {
                                      if (index ==
                                          controller
                                              .model.value.jobs!.data!.length) {
                                        return (controller.model.value.jobs!
                                                    .lastPage! >
                                                controller.currentPage.value)
                                            ? Column(
                                                children: [
                                                  const SizedBox(height: 5.0),
                                                  GestureDetector(
                                                    onTap: () {
                                                      controller.fetchJobs("",
                                                          page: controller
                                                                  .currentPage
                                                                  .value +
                                                              1);
                                                    },
                                                    child: Container(
                                                      height: 30,
                                                      width: Get.width / 2,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                        border: Border.all(
                                                          color:
                                                              LightThemeColors
                                                                  .primaryColor,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          'আরও দেখুন',
                                                          style: TextStyle(
                                                            color:
                                                                LightThemeColors
                                                                    .primaryColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.shrink();
                                      }

                                      var data = controller
                                          .model.value.jobs!.data![index];
                                      final jobTitle = (data.title != null && data.title!.trim().isNotEmpty)
                                          ? data.title!.trim()
                                          : (data.companyName?.trim().isNotEmpty == true
                                              ? data.companyName!.trim()
                                              : "");
                                      return GovJobCard(
                                        title: jobTitle,
                                        onTap: () {
                                          debugPrint("1x. ${data.id}");
                                          Get.toNamed(
                                            Routes.JOB_DETAILS,
                                            arguments: data.id,
                                          );
                                        },
                                        deadline: data.deadline,
                                      );
                                    },
                                    separatorBuilder: (x, i) =>
                                        const SizedBox(height: 5.0),
                                  ),
                                ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

String displayDeadline(DateTime? deadline) {
  if (deadline == null) {
    return 'unknown';
  }

  // Adjust the deadline if hour and minute are 0
  final adjustedDeadline = (deadline.hour == 0 && deadline.minute == 0)
      ? deadline.add(const Duration(hours: 23, minutes: 59, seconds: 59))
      : deadline;

  // Return formatted deadline text
  return DateFormatter.formatJobDeadline(adjustedDeadline);
}

class GovJobCard extends StatelessWidget {
  final String title;
  final DateTime? deadline;
  final void Function()? onTap;

  const GovJobCard({
    super.key,
    required this.title,
    required this.onTap,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    // Use a simplified method to get the deadline text or an empty string
    final deadlineText = displayDeadline(deadline);
    final isDeadlineOver =
        deadline != null && DateTime.now().isAfter(deadline!);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: Get.height / 12),
        decoration: BoxDecoration(
          color: isDeadlineOver
              ? (context.isDark
                  ? const Color(0xFF4C0519).withValues(alpha: 0.4)
                  : Colors.red.shade50)
              : context.cardColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isDeadlineOver
                ? (context.isDark ? const Color(0xFFF43F5E) : Colors.red)
                : context.borderColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyles.heading5.copyWith(
                color: isDeadlineOver
                    ? (context.isDark
                        ? const Color(0xFFFDA4AF)
                        : Colors.red.shade900)
                    : context.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
              const SizedBox(height: 4.00),
              if (deadlineText.isNotEmpty)
                Text(
                  "আবেদনের শেষ তারিখ: $deadlineText",
                  style: AppTextStyles.heading6.copyWith(
                    color: isDeadlineOver
                        ? (context.isDark
                            ? const Color(0xFFFECDD3)
                            : Colors.red.shade700)
                        : context.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    }
  }
