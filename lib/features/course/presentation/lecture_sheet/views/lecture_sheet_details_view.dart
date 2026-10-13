import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';

class LectureSheetDetailsView extends ConsumerWidget {
  final int id;
  const LectureSheetDetailsView({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sheetDetailsNotifierProvider(id));

    return Scaffold(
      appBar: CustomAppBar(title: "Sheet Details"),
      body: Builder(
        builder: (context) {
          final data = state.model;
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError) {
            return Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(color: context.textPrimary),
              ),
            );
          }

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
        },
      ),
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
    final fullFileUrl = Endpoints.storageUrl + fileUrl;
    final theme = Theme.of(context);

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

            SizedBox(height: (description ?? '').isNotEmpty ? 0 : 10.h),

            /// Description
            (description ?? '').isNotEmpty
                ? Text(
                    description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.textSecondary,
                    ),
                  )
                : const SizedBox(),

            /// Label
            Text(
              "Attached File",
              style: theme.textTheme.titleMedium?.copyWith(
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
