import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/core/core.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/course/course.dart';

class CourseLearnBody extends StatefulWidget {
  final CourseLearningModel model;
  final VoidCallback? onPlayPrev;
  final VoidCallback? onPlayNext;

  const CourseLearnBody({
    super.key,
    required this.model,
    this.onPlayPrev,
    this.onPlayNext,
  });

  @override
  State<CourseLearnBody> createState() => _CourseLearnBodyState();
}

class _CourseLearnBodyState extends State<CourseLearnBody> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final currentItem = model.data?.currentItem;
    if (currentItem == null) {
      return const Center(child: Text("কোনো কন্টেন্ট পাওয়া যায়নি"));
    }

    final bool isExamContent = currentItem.hasExam == true ||
        currentItem.examInfo != null ||
        currentItem.examId != null;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExamContent) ...[
            _ClassroomExamCard(
              item: currentItem,
              courseTitle: model.data?.course?.title,
            ),
            const SizedBox(height: 12),
          ] else if (currentItem.pdf != null && currentItem.pdf!.isNotEmpty) ...[
            SizedBox(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    SfPdfViewer.network(
                      Endpoints.storageUrl + currentItem.pdf!,
                      canShowScrollStatus: false,
                      canShowScrollHead: false,
                      enableDoubleTapZooming: false,
                      pageSpacing: 0,
                      maxZoomLevel: 1.0,
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfViewerScreen(
                                  title: currentItem.title.toString(),
                                  file: Endpoints.storageUrl +
                                      currentItem.pdf!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else if (currentItem.image != null &&
              currentItem.image!.isNotEmpty) ...[
            SizedBox(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: Endpoints.storageUrl + currentItem.image!,
                      fit: BoxFit.cover, // Makes image cover the area nicely
                      width: double.infinity, // Expand to full width of parent
                      height: 200, // Set fixed height or flexible as needed
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullscreenImageView(
                                  imageUrl: Endpoints.storageUrl +
                                      currentItem.image!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (!isExamContent) ...[
            Text(
              currentItem.title ?? 'Untitled Content',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Navigation buttons
          Row(
            children: [
              if (model.data?.prevItemId != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onPlayPrev,
                    icon: const Icon(Icons.skip_previous, size: 18),
                    label: Text("Previous"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (model.data?.prevItemId != null &&
                  model.data?.nextItemId != null)
                const SizedBox(width: 12),
              if (model.data?.nextItemId != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onPlayNext,
                    icon: const Icon(Icons.skip_next, size: 18),
                    label: Text("Next"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightThemeColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Image Button
                if (currentItem.image != null &&
                    currentItem.image!.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullscreenImageView(
                            imageUrl:
                                Endpoints.storageUrl + currentItem.image!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.image),
                    label: Text("ViewImage"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],

                // PDF Button
                if (currentItem.pdf != null && currentItem.pdf!.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(
                            title: currentItem.title.toString(),
                            file: Endpoints.storageUrl + currentItem.pdf!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text("ViewPdf"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],

                // File Button
                if (currentItem.file != null &&
                    currentItem.file!.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          Endpoints.storageUrl + currentItem.file!));
                    },
                    icon: const Icon(Icons.insert_drive_file),
                    label: Text("Download File"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],

                //  YT Playlist
                if (currentItem.youtubePlaylist != null &&
                    currentItem.youtubePlaylist!.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      launchUrl(Uri.parse(Endpoints.storageUrl +
                          currentItem.youtubePlaylist!));
                    },
                    icon: const Icon(Icons.list),
                    label: Text("Playlist"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Description
          if (currentItem.details != null &&
              currentItem.details!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: ClipRect(
                    child: SizedBox(
                      height: 100, // Adjust height for approx. 3 lines of HTML
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: HtmlWidget(
                          onTapUrl: (url) {
                            launchUrlString(url.toString());
                            return true;
                          },
                          currentItem.details!,
                        ),
                      ),
                    ),
                  ),
                  secondChild: HtmlWidget(
                    onTapUrl: (url) {
                      launchUrlString(url.toString());
                      return true;
                    },
                    currentItem.details!,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? 'Read Less ' : "Read More",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ClassroomExamCard extends StatelessWidget {
  final CourseItem item;
  final String? courseTitle;

  const _ClassroomExamCard({
    required this.item,
    this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    final examInfo = item.examInfo;
    final int? examId = item.examId ?? examInfo?.examId;
    final String examTitle = examInfo?.title ?? item.title ?? 'পরীক্ষা';
    final latestResult = examInfo?.latestResult;
    final bool hasAttempted = examInfo?.hasAttempted == true || latestResult != null;
    final bool isPassed = (latestResult?.resultStatus?.toLowerCase() == 'passed') ||
        ((latestResult?.scorePercent ?? 0) >= 40);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF006A4E).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006A4E).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF006A4E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006A4E),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.moduleTitle != null && item.moduleTitle!.isNotEmpty)
                        Text(
                          item.moduleTitle!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF006A4E),
                          ),
                        ),
                      Text(
                        examTitle,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (item.isCompleted == true)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          'সম্পন্ন',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics / Exam rules row
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (examInfo?.duration != null)
                      _buildChip(
                        Icons.timer_outlined,
                        '${examInfo!.duration} মিনিট',
                        const Color(0xFF006A4E),
                      ),
                    if (latestResult?.totalQuestions != null || examInfo?.positiveMark != null)
                      _buildChip(
                        Icons.help_outline_rounded,
                        latestResult?.totalQuestions != null
                            ? '${latestResult!.totalQuestions} টি প্রশ্ন'
                            : 'পজিটিভ মার্ক: +${examInfo?.positiveMark ?? 1}',
                        Colors.blue.shade700,
                      ),
                    if (examInfo?.negativeMark != null && examInfo!.negativeMark! > 0)
                      _buildChip(
                        Icons.remove_circle_outline_rounded,
                        'নেগেটিভ: -${examInfo.negativeMark}',
                        Colors.orange.shade800,
                      ),
                  ],
                ),

                // Details HTML if available
                if ((item.detailsHtml ?? item.details ?? '').trim().isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: context.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: context.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: HtmlWidget(item.detailsHtml ?? item.details!),
                  ),
                ],

                // Previous Attempt / Result Card
                if (hasAttempted && latestResult != null) ...[
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? Colors.green.withValues(alpha: 0.08)
                          : Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isPassed
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPassed ? Icons.verified_rounded : Icons.cancel_rounded,
                              color: isPassed ? Colors.green : Colors.red,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'সর্বশেষ ফলাফল: ${latestResult.resultStatus ?? (isPassed ? "উত্তীর্ণ" : "অনুত্তীর্ণ")}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5.sp,
                                  color: isPassed ? Colors.green.shade800 : Colors.red.shade800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: (isPassed ? Colors.green : Colors.red).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'প্রাপ্ত নম্বর: ${latestResult.score ?? 0}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: isPassed ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'সঠিক: ${latestResult.correctAnswers ?? 0} | ভুল: ${latestResult.incorrectAnswers ?? 0}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (latestResult.attemptedAt != null) ...[
                              SizedBox(width: 6.w),
                              Text(
                                latestResult.attemptedAt!,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: context.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 14.h),

                // Interactive Buttons
                Row(
                  children: [
                    // Start / Retake Exam Button
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (examId != null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => ExamDetailsDialog(
                                examId: examId,
                                title: examTitle,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(
                          hasAttempted ? 'আবার পরীক্ষা দিন' : 'পরীক্ষা দিন',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006A4E),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 1,
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Results or Read Questions Button
                    if (latestResult?.resultId != null && examId != null) ...[
                      Expanded(
                        flex: 5,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final token = MySharedPref.getUserToken();
                            final webviewUrl = Endpoints.v1ExamWebviewResult(
                              examId,
                              latestResult!.resultId!,
                              token: token,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WebExamView(
                                  title: 'ফলাফল ও সমাধান',
                                  url: webviewUrl,
                                  examId: examId,
                                  mode: ExamWebViewMode.result,
                                  isExamRunning: false,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics_outlined, size: 18),
                          label: Text(
                            'ফলাফল',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF006A4E),
                            side: const BorderSide(color: Color(0xFF006A4E)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ] else if (examId != null) ...[
                      Expanded(
                        flex: 5,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final token = MySharedPref.getUserToken();
                            final webviewUrl = Endpoints.v1ExamWebviewRead(
                              examId,
                              token: token,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WebExamView(
                                  title: '$examTitle (প্রশ্ন পড়ুন)',
                                  url: webviewUrl,
                                  examId: examId,
                                  mode: ExamWebViewMode.read,
                                  isExamRunning: false,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          label: Text(
                            'প্রশ্ন পড়ুন',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF006A4E),
                            side: const BorderSide(color: Color(0xFF006A4E)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
