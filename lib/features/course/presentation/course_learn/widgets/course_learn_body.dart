import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/core/core.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/course/course.dart';
import 'full_screen_image_view.dart';

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentItem!.pdf != null && currentItem.pdf!.isNotEmpty) ...[
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
          ] else if (currentItem.examId != null) ...[
            SizedBox(
                width: double.infinity,
                child: ExamCard(
                  showAttempt: false,
                  exam: currentItem.exam!,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ExamDetailsDialog(
                        exam: currentItem.exam!,
                      ),
                    );
                  },
                )),
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

          Text(
            currentItem.title ?? 'Untitled Content',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

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
