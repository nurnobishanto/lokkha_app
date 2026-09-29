import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/jobs/jobs.dart';
import 'package:lokkha/core/core.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:lokkha/core/utils/date_formatter.dart';

class JobDetailsScreen extends StatelessWidget {
  final int id;
  JobDetailsScreen({super.key, required this.id});
  final JobsController controller = Get.put(JobsController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getSingleJob(id);
    });

    debugPrint("govJob Id: $id ");

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "চাকরির বিস্তারিত",
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final jobData = controller.detailsModel.value;
          // Check if deadline is over
          final isDeadlineOver = jobData.deadline != null &&
              DateTime.now().isAfter(jobData.deadline!);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDeadlineOver
                            ? (context.isDark
                                ? const Color(0xFF4C0519).withValues(alpha: 0.4)
                                : Colors.red.shade50)
                            : context.cardColor,
                        border: Border.all(
                          color: isDeadlineOver
                              ? (context.isDark ? const Color(0xFFF43F5E) : Colors.red)
                              : context.borderColor,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    jobData.companyName == null
                                        ? ''
                                        : jobData.companyName.toString(),
                                    style: AppTextStyles.heading5.copyWith(color: context.textPrimary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              "প্রকাশিত: ${DateFormatter.formatJobDeadline(jobData.createdAt)}",
                              style: AppTextStyles.heading5.copyWith(color: context.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              "আবেদনের শেষ তারিখ: ${DateFormatter.formatJobDeadline(jobData.deadline)}",
                              style: AppTextStyles.heading5.copyWith(
                                color: isDeadlineOver
                                    ? (context.isDark ? const Color(0xFFFDA4AF) : Colors.red.shade700)
                                    : context.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              "সোর্স: ${jobData.source ?? ''}",
                              style: AppTextStyles.heading5.copyWith(color: context.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10.0),

                            // PDF or Image Viewer
                            jobData.sourceFile!.contains("pdf")
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
                                    child: SfPdfViewer.network(
                                      getFullUrl(jobData.sourceFile),
                                    ))
                                : SizedBox(
                                    width: double.infinity,
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      minScale: 0.5,
                                      maxScale: 4.5,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "${AppConstants.storageUrl}${jobData.sourceFile.toString()}",
                                        fit: BoxFit.fitHeight,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
