import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/lecture_sheet.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/core/network/api_call_status.dart';

class LectureSheetListDetailsView extends StatelessWidget {
  final int id;
  const LectureSheetListDetailsView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LectureSheetListDetailsController());
    controller.setCategoryId(id);

    return Scaffold(
      appBar: CustomAppBar(title: "Lecture Sheet Details"),
      body: Obx(() {
        switch (controller.apiCallStatus.value) {
          case ApiCallStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case ApiCallStatus.success:
            final model = controller.detailsModel.value;
            if (model == null) {
              return Center(
                child: Text(
                  "No Data Found",
                  style: TextStyle(color: context.textPrimary),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView(
                  children: [
                    /// Name
                    Text(
                      model.category?.name ?? '',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// Description
                    Text(
                      model.category?.description ?? '',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: context.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    /// Sheet Count
                    Row(
                      children: [
                        Icon(Icons.insert_drive_file_rounded,
                            size: 20, color: context.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Total Sheets: ${model.category?.lecturesheetsCount ?? 0}",
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /// List of Sheets
                    ...controller.lectureSheets.map(
                      (sheet) => GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.SHEET_DETAILS,
                                arguments: sheet.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 7,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.description,
                                    size: 21, color: Colors.blue),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(sheet.name ?? 'No title',
                                      style: AppTextStyles.heading5
                                          .copyWith(color: context.textPrimary)),
                                ),
                                Icon(Icons.chevron_right,
                                    size: 14, color: context.textMuted),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            );
          case ApiCallStatus.error:
            return Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(color: context.textPrimary),
              ),
            );
          case ApiCallStatus.holding:
          default:
            return const SizedBox();
        }
      }),
    );
  }
}

Widget buildSheetTile(LectureSheet sheet, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Get.toNamed(Routes.SHEET_DETAILS, arguments: sheet.id);
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.description_rounded, size: 32, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sheet.name ?? 'No title',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: context.textMuted),
        ],
      ),
    ),
  );
}
