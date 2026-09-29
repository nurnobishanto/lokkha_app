import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:lokkha/core/core.dart';

class RoutineBottomSheet extends StatelessWidget {
  final String fileUrl;
  const RoutineBottomSheet({super.key, required this.fileUrl});

  bool get isPdf => fileUrl.toLowerCase().endsWith(".pdf");

  @override
  Widget build(BuildContext context) {
    final fullUrl = AppConstants.storageUrl + fileUrl;
    debugPrint("Routine File URL: $fullUrl");

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LightThemeColors.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text("Routine", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Expanded(
              child: isPdf
                  ? SfPdfViewer.network(fullUrl)
                  : InteractiveViewer(
                      child: Image.network(
                        fullUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Text("Failed to load image")),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
