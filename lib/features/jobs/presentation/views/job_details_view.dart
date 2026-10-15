import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/jobs/jobs.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends ConsumerWidget {
  final int id;
  const JobDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("govJob Id: $id ");
    final state = ref.watch(jobDetailsNotifierProvider(id));

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "চাকরির বিস্তারিত",
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final jobData = state.job;
          if (jobData == null) {
            return Center(
              child: Text(state.error ?? "তথ্য পাওয়া যায়নি"),
            );
          }

          final isDeadlineOver = jobData.deadline != null &&
              DateTime.now().isAfter(jobData.deadline!);

          final rawFile = (jobData.imageUrl != null &&
                  jobData.imageUrl!.trim().isNotEmpty)
              ? jobData.imageUrl!.trim()
              : (jobData.sourceFile != null &&
                      jobData.sourceFile!.trim().isNotEmpty
                  ? jobData.sourceFile!.trim()
                  : '');

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
                              ? (context.isDark
                                  ? const Color(0xFFF43F5E)
                                  : Colors.red)
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
                                    (jobData.title != null &&
                                            jobData.title!.trim().isNotEmpty)
                                        ? jobData.title!.trim()
                                        : (jobData.companyName ?? ''),
                                    style: AppTextStyles.heading5
                                        .copyWith(color: context.textPrimary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (jobData.companyName != null &&
                                jobData.companyName!.trim().isNotEmpty &&
                                jobData.companyName!.trim() !=
                                    jobData.title?.trim()) ...[
                              const SizedBox(height: 2.0),
                              Text(
                                "প্রতিষ্ঠান: ${jobData.companyName!.trim()}",
                                style: AppTextStyles.heading6
                                    .copyWith(color: context.primaryColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 2.0),
                            Text(
                              "প্রকাশিত: ${DateFormatter.formatJobDeadline(jobData.createdAt)}",
                              style: AppTextStyles.heading5
                                  .copyWith(color: context.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              "আবেদনের শেষ তারিখ: ${DateFormatter.formatJobDeadline(jobData.deadline)}",
                              style: AppTextStyles.heading5.copyWith(
                                color: isDeadlineOver
                                    ? (context.isDark
                                        ? const Color(0xFFFDA4AF)
                                        : Colors.red.shade700)
                                    : context.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (jobData.source != null &&
                                jobData.source!.trim().isNotEmpty) ...[
                              const SizedBox(height: 5.0),
                              Text(
                                "সোর্স: ${jobData.source!.trim()}",
                                style: AppTextStyles.heading5
                                    .copyWith(color: context.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (jobData.vacancy != null &&
                                jobData.vacancy!.trim().isNotEmpty) ...[
                              const SizedBox(height: 5.0),
                              Text(
                                "পদসংখ্যা: ${jobData.vacancy!.trim()}",
                                style: AppTextStyles.heading5
                                    .copyWith(color: context.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (jobData.salary != null &&
                                jobData.salary!.trim().isNotEmpty) ...[
                              const SizedBox(height: 5.0),
                              Text(
                                "বেতন: ${jobData.salary!.trim()}",
                                style: AppTextStyles.heading5
                                    .copyWith(color: context.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (jobData.ageLimit != null &&
                                jobData.ageLimit!.trim().isNotEmpty) ...[
                              const SizedBox(height: 5.0),
                              Text(
                                "বয়সসীমা: ${jobData.ageLimit!.trim()}",
                                style: AppTextStyles.heading5
                                    .copyWith(color: context.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (jobData.details != null &&
                                jobData.details!.trim().isNotEmpty) ...[
                              const SizedBox(height: 10.0),
                              Text(
                                jobData.details!.trim(),
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                            if (jobData.applicationLink != null &&
                                jobData.applicationLink!.trim().isNotEmpty) ...[
                              const SizedBox(height: 12.0),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final uri = Uri.tryParse(
                                        jobData.applicationLink!.trim());
                                    if (uri != null &&
                                        await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  label: const Text(
                                    "আবেদন করুন",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        LightThemeColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10.0),

                            // PDF or Image Viewer
                            if (rawFile.isNotEmpty) ...[
                              if (rawFile.toLowerCase().contains("pdf"))
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: SfPdfViewer.network(
                                    (rawFile.startsWith("http://") ||
                                            rawFile.startsWith("https://"))
                                        ? rawFile
                                        : "${Endpoints.storageUrl}$rawFile",
                                  ),
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4.5,
                                    child: CachedNetworkImage(
                                      imageUrl: (rawFile.startsWith("http://") ||
                                              rawFile.startsWith("https://"))
                                          ? rawFile
                                          : "${Endpoints.storageUrl}$rawFile",
                                      fit: BoxFit.fitHeight,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                            ],
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
