import 'package:flutter/material.dart';
import 'package:lokkha/core/core.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key, required this.title, required this.file});
  final String title;
  final String file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title.toString(),
          style: AppTextStyles.heading4.copyWith(color: LightThemeColors.white),
        ),
        backgroundColor: LightThemeColors.primaryColor,
        iconTheme: const IconThemeData(
          color: LightThemeColors.white, // Change the back icon color here
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SfPdfViewer.network(file.toString()),
            ),
          ],
        ),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          launchUrlString(file);
        },
        icon: const Icon(
          Icons.download,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'ডাউনলোড',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: LightThemeColors.primaryColor,
      ),

    );
  }
}
