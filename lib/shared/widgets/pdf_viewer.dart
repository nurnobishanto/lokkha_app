import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.file,
  });

  final String title;
  final String file;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfController;
  bool _isTransitionComplete = false;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();

    // Guard against RenderFractionalTranslation assertion during route transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modalRoute = ModalRoute.of(context);
      if (modalRoute == null ||
          modalRoute.animation == null ||
          modalRoute.animation!.isCompleted) {
        if (mounted) setState(() => _isTransitionComplete = true);
      } else {
        void handleStatus(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            modalRoute.animation?.removeStatusListener(handleStatus);
            // Delay one extra frame to ensure render tree has completed layout
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _isTransitionComplete = true);
            });
          }
        }

        modalRoute.animation!.addStatusListener(handleStatus);
      }
    });
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _downloadPdf() {
    final fileUrl = widget.file.trim();
    if (fileUrl.isNotEmpty) {
      launchUrlString(fileUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.heading4.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: LightThemeColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'ডাউনলোড',
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isTransitionComplete)
            SfPdfViewer.network(
              widget.file,
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
                if (mounted) {
                  setState(() => _currentPage = details.newPageNumber);
                }
              },
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _pageCount = details.document.pages.count;
                  });
                }
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = details.description;
                  });
                }
              },
            ),

          // Loading Indicator
          if (!_isTransitionComplete || _isLoading)
            Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error Fallback
          if (_errorMessage != null)
            Container(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              padding: EdgeInsets.all(24.r),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 44.sp,
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'পিডিএফ লোড করতে সমস্যা হয়েছে',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: _downloadPdf,
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: const Text('ব্রাউজারে খুলুন / ডাউনলোড'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LightThemeColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Navigation Indicator
          if (_isTransitionComplete && !_isLoading && _pageCount > 0)
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
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
                            size: 14.sp,
                            color: _currentPage > 1
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        '$_currentPage / $_pageCount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: _currentPage < _pageCount
                            ? () => _pdfController.nextPage()
                            : null,
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14.sp,
                            color: _currentPage < _pageCount
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
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
    );
  }
}
