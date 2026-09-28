import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/components/custom_app_bar.dart';
import 'package:lokkha/app/components/custom_network_image_card.dart';
import 'package:lokkha/app/services/api_call_status.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import 'package:lokkha/styles/text_style.dart';
import 'package:lokkha/utils/constants.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../controllers/sheet_details_controller.dart';

class LectureSheetDetailsView extends GetView<SheetDetailsController> {
  const LectureSheetDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sheet Details"),
      body: Obx(() {
        final data = controller.model.value;
        final status = controller.apiCallStatus.value;

        switch (status) {
          case ApiCallStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case ApiCallStatus.error:
            return Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(color: context.textPrimary),
              ),
            );

          case ApiCallStatus.success:
            if (data == null || data.lectureSheet == null) {
              return Center(
                child: Text(
                  "No data available",
                  style: TextStyle(color: context.textPrimary),
                ),
              );
            }
            final sheet = data.lectureSheet!;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LectureSheetCard(
                  name: sheet.name ?? '',
                  description: sheet.details ?? '',
                  fileUrl: sheet.file ?? '',
                ),
              ),
            );
          default:
            return const SizedBox();
        }
      }),
    );
  }
}

class LectureSheetCard extends StatelessWidget {
  final String name;
  final String? description;
  final String fileUrl;

  const LectureSheetCard({
    super.key,
    required this.name,
    required this.description,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = fileUrl.toLowerCase().endsWith('.pdf');
    final fullFileUrl = AppConstants.storageUrl + fileUrl;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Name
            Text(
              name,
              style: AppTextStyles.heading4.copyWith(color: context.textPrimary),
            ),

            SizedBox(height: description!.isNotEmpty ? 0 : 10.h),

            /// Description
            description!.isNotEmpty
                ? Text(
                    description!,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.textSecondary,
                    ),
                  )
                : const SizedBox(),

            /// Label
            Text(
              "Attached File",
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            /// File Preview (PDF or Image)
            isPdf
                ? Flexible(
                    child: SfPdfViewer.network(fullFileUrl),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomNetworkImageCard(
                      imageUrl: fullFileUrl,
                    ),
                  ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
