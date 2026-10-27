import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/jobs/jobs.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends ConsumerWidget {
  final int id;
  const JobDetailsScreen({super.key, required this.id});

  String _prepareJobHtml(String rawHtml) {
    var html = rawHtml.trim();

    // 1. Clean empty paragraphs or awkward leading <br> inside <p>
    html = html.replaceAll(
        RegExp(r'<p>\s*<br\s*/?>', caseSensitive: false), '<p>');

    // 2. Remove redundant empty paragraph tags
    html = html.replaceAll(
        RegExp(r'<p>\s*(&nbsp;|\s)*</p>', caseSensitive: false), '');

    // 3. Auto-convert plain text URLs not wrapped in <a> into clickable hyperlinks
    final urlRegex = RegExp(
      r'(?<!href=["' r"'" r'])(https?://[^\s<]+)',
      caseSensitive: false,
    );
    html = html.replaceAllMapped(urlRegex, (match) {
      final url = match.group(1)!;
      return '<a href="$url">$url</a>';
    });

    return html;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobDetailsNotifierProvider(id));

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: const CustomAppBar(
        title: "চাকরির বিস্তারিত",
        centerTitle: true,
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
              child: Text(
                state.error ?? "তথ্য পাওয়া যায়নি",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.textPrimary,
                ),
              ),
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

          final fullFileUrl = (rawFile.startsWith("http://") ||
                  rawFile.startsWith("https://"))
              ? rawFile
              : "${Endpoints.storageUrl}$rawFile";

          final isPdf = rawFile.toLowerCase().contains("pdf");

          final title = (jobData.title != null &&
                  jobData.title!.trim().isNotEmpty)
              ? jobData.title!.trim()
              : (jobData.companyName ?? 'চাকরির বিজ্ঞপ্তি');

          final detailsContent = (jobData.details != null &&
                  jobData.details!.trim().isNotEmpty)
              ? jobData.details!.trim()
              : (jobData.description != null &&
                      jobData.description!.trim().isNotEmpty
                  ? jobData.description!.trim()
                  : '');

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── 1. Main Job Information Card ──────────────────────────
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: isDeadlineOver
                        ? (context.isDark
                            ? const Color(0xFF4C0519).withValues(alpha: 0.3)
                            : Colors.red.shade50.withValues(alpha: 0.7))
                        : (context.isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDeadlineOver
                          ? (context.isDark
                              ? const Color(0xFFF43F5E)
                              : Colors.red.shade300)
                          : context.borderColor.withValues(alpha: 0.7),
                      width: isDeadlineOver ? 1.4 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: context.isDark ? 0.25 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDeadlineOver
                                  ? (context.isDark
                                      ? Colors.red.withValues(alpha: 0.2)
                                      : Colors.red.shade100)
                                  : (context.isDark
                                      ? const Color(0xFF064E3B)
                                      : const Color(0xFFE8F5E9)),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isDeadlineOver
                                      ? Icons.timer_off_outlined
                                      : Icons.check_circle_outline_rounded,
                                  size: 12.sp,
                                  color: isDeadlineOver
                                      ? Colors.red.shade700
                                      : const Color(0xFF006A4E),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  isDeadlineOver
                                      ? 'আবেদনের সময় শেষ'
                                      : 'আবেদন চলমান',
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDeadlineOver
                                        ? Colors.red.shade700
                                        : const Color(0xFF006A4E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (jobData.views != null && jobData.views! > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 13.sp,
                                  color: context.textMuted,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${jobData.views} বার দেখা হয়েছে',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: context.textMuted,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // Job Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          height: 1.3,
                        ),
                      ),

                      if (jobData.companyName != null &&
                          jobData.companyName!.trim().isNotEmpty &&
                          jobData.companyName!.trim() != title) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 14.sp,
                              color: context.primaryColor,
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: Text(
                                jobData.companyName!.trim(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: 12.h),
                      Divider(
                        height: 1,
                        thickness: 0.7,
                        color: context.borderColor.withValues(alpha: 0.6),
                      ),
                      SizedBox(height: 10.h),

                      // Key Attribute Rows
                      _buildMetaRow(
                        context,
                        icon: Icons.calendar_today_rounded,
                        iconColor: const Color(0xFF0284C7),
                        label: 'প্রকাশিত',
                        value:
                            DateFormatter.formatJobDeadline(jobData.createdAt),
                      ),
                      _buildMetaRow(
                        context,
                        icon: Icons.alarm_rounded,
                        iconColor: isDeadlineOver
                            ? const Color(0xFFE11D48)
                            : const Color(0xFFD97706),
                        label: 'আবেদনের শেষ তারিখ',
                        value:
                            DateFormatter.formatJobDeadline(jobData.deadline),
                        valueColor: isDeadlineOver
                            ? const Color(0xFFE11D48)
                            : (context.isDark
                                ? const Color(0xFFFDE047)
                                : const Color(0xFFB45309)),
                        isBold: true,
                      ),
                      if (jobData.source != null &&
                          jobData.source!.trim().isNotEmpty)
                        _buildMetaRow(
                          context,
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF059669),
                          label: 'সোর্স',
                          value: jobData.source!.trim(),
                        ),
                      if (jobData.vacancy != null &&
                          jobData.vacancy!.trim().isNotEmpty)
                        _buildMetaRow(
                          context,
                          icon: Icons.people_alt_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          label: 'পদসংখ্যা',
                          value: jobData.vacancy!.trim(),
                          isBold: true,
                        ),
                      if (jobData.salary != null &&
                          jobData.salary!.trim().isNotEmpty)
                        _buildMetaRow(
                          context,
                          icon: Icons.payments_rounded,
                          iconColor: const Color(0xFF0D9488),
                          label: 'বেতন',
                          value: jobData.salary!.trim(),
                        ),
                      if (jobData.ageLimit != null &&
                          jobData.ageLimit!.trim().isNotEmpty)
                        _buildMetaRow(
                          context,
                          icon: Icons.hourglass_bottom_rounded,
                          iconColor: const Color(0xFFEA580C),
                          label: 'বয়সসীমা',
                          value: jobData.ageLimit!.trim(),
                        ),

                      // Application Button
                      if (jobData.applicationLink != null &&
                          jobData.applicationLink!.trim().isNotEmpty) ...[
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          height: 44.h,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.tryParse(
                                  jobData.applicationLink!.trim());
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            icon: const Icon(Icons.open_in_new_rounded, size: 17),
                            label: Text(
                              "আবেদন করুন",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LightThemeColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ─── 2. Job Details / Description Card (Clean HTML Render) ──
                if (detailsContent.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.7),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: context.isDark ? 0.25 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5.5.r),
                              decoration: BoxDecoration(
                                color: context.primaryColor
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.article_outlined,
                                size: 15.sp,
                                color: context.primaryColor,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'বিস্তারিত নির্দেশনা ও সার্কুলার বিবরণ',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Divider(
                          height: 1,
                          thickness: 0.7,
                          color: context.borderColor.withValues(alpha: 0.6),
                        ),
                        SizedBox(height: 12.h),

                        // Human-readable HTML Rendering
                        HtmlWidget(
                          _prepareJobHtml(detailsContent),
                          textStyle: TextStyle(
                            color: context.textPrimary,
                            fontSize: 13.5.sp,
                            height: 1.6,
                          ),
                          customStylesBuilder: (element) {
                            if (element.localName == 'a') {
                              return {
                                'color': '#006A4E',
                                'text-decoration': 'underline',
                                'font-weight': '600',
                              };
                            }
                            if (element.localName == 'p') {
                              return {
                                'margin-bottom': '8px',
                              };
                            }
                            return null;
                          },
                          onTapUrl: (url) async {
                            final uri = Uri.tryParse(url);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              return true;
                            }
                            return false;
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // ─── 3. Official Circular File (Smooth PDF or Image Viewer) ─
                if (rawFile.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  if (isPdf)
                    _JobPdfViewerCard(
                      pdfUrl: fullFileUrl,
                      jobTitle: title,
                    )
                  else
                    _JobImageViewerCard(
                      imageUrl: fullFileUrl,
                      jobTitle: title,
                    ),
                ],

                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12.5.sp, color: iconColor),
          ),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? context.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Smooth & Responsive PDF Viewer Component ───────────────────────────────
class _JobPdfViewerCard extends StatefulWidget {
  final String pdfUrl;
  final String jobTitle;

  const _JobPdfViewerCard({
    required this.pdfUrl,
    required this.jobTitle,
  });

  @override
  State<_JobPdfViewerCard> createState() => _JobPdfViewerCardState();
}

class _JobPdfViewerCardState extends State<_JobPdfViewerCard> {
  late final PdfViewerController _pdfController;
  int _currentPage = 1;
  int _pageCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          title: widget.jobTitle,
          file: widget.pdfUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Full-Screen and Download Shortcuts
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5.5.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 15.sp,
                    color: const Color(0xFFE11D48),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'অফিসিয়াল সার্কুলার (পিডিএফ)',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      if (_pageCount > 0)
                        Text(
                          '$_currentPage / $_pageCount পাতা',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: context.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                // Full Screen Action Button
                InkWell(
                  onTap: () => _openFullScreen(context),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: context.primaryColor.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen_rounded,
                          size: 15.sp,
                          color: context.primaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'ফুল স্ক্রিন',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                // Download Action Button
                IconButton(
                  onPressed: () async {
                    final uri = Uri.tryParse(widget.pdfUrl);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: Icon(
                    Icons.download_rounded,
                    size: 18.sp,
                    color: context.textSecondary,
                  ),
                  tooltip: 'ডাউনলোড করুন',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.all(5.r),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 0.7,
            color: context.borderColor.withValues(alpha: 0.6),
          ),

          // Embedded PDF Viewer with Smooth Continuous Layout
          SizedBox(
            height: 480.h,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
              child: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) => true,
                    child: SfPdfViewer.network(
                      widget.pdfUrl,
                      controller: _pdfController,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      canShowPaginationDialog: true,
                      enableDoubleTapZooming: true,
                      interactionMode: PdfInteractionMode.pan,
                      pageLayoutMode: PdfPageLayoutMode.continuous,
                      scrollDirection: PdfScrollDirection.vertical,
                      pageSpacing: 4,
                      onPageChanged: (PdfPageChangedDetails details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        setState(() {
                          _isLoading = false;
                          _pageCount = details.document.pages.count;
                        });
                      },
                      onDocumentLoadFailed:
                          (PdfDocumentLoadFailedDetails details) {
                        setState(() {
                          _isLoading = false;
                          _errorMessage = details.description;
                        });
                      },
                    ),
                  ),

                  // Loading State
                  if (_isLoading)
                    Container(
                      color: context.isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  // Error State
                  if (_errorMessage != null)
                    Container(
                      color: context.isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      padding: EdgeInsets.all(16.r),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 32.sp,
                              color: Colors.redAccent,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'পিডিএফ লোড করতে সমস্যা হয়েছে',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            ElevatedButton.icon(
                              onPressed: () => _openFullScreen(context),
                              icon: const Icon(Icons.open_in_browser, size: 16),
                              label: const Text('ব্রাউজারে খুলুন'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Floating Navigation Controls Pill
                  if (!_isLoading && _pageCount > 0)
                    Positioned(
                      bottom: 12.h,
                      left: 14.w,
                      right: 14.w,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: (context.isDark
                                    ? Colors.black
                                    : const Color(0xFF1E293B))
                                .withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(25.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: _currentPage > 1
                                    ? () => _pdfController.previousPage()
                                    : null,
                                child: Padding(
                                  padding: EdgeInsets.all(4.r),
                                  child: Icon(
                                    Icons.arrow_back_ios_rounded,
                                    size: 13.sp,
                                    color: _currentPage > 1
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '$_currentPage / $_pageCount',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              InkWell(
                                onTap: _currentPage < _pageCount
                                    ? () => _pdfController.nextPage()
                                    : null,
                                child: Padding(
                                  padding: EdgeInsets.all(4.r),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 13.sp,
                                    color: _currentPage < _pageCount
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Container(
                                width: 1,
                                height: 14.h,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              SizedBox(width: 6.w),
                              InkWell(
                                onTap: () => _openFullScreen(context),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fullscreen_rounded,
                                        size: 14.sp,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        'বড় করে পড়ুন',
                                        style: TextStyle(
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Image Viewer Component ────────────────────────────────────────────────
class _JobImageViewerCard extends StatelessWidget {
  final String imageUrl;
  final String jobTitle;

  const _JobImageViewerCard({
    required this.imageUrl,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 16.sp,
                  color: context.primaryColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  'অফিসিয়াল সার্কুলার ছবি',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.7,
            color: context.borderColor.withValues(alpha: 0.6),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
            ),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.5,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.fitWidth,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  height: 200.h,
                  color: context.surfaceSubtle,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120.h,
                  color: context.surfaceSubtle,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
