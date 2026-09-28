import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePreviewPage extends StatelessWidget {
  final String url;
  const ImagePreviewPage({super.key, required this.url});

  Future<void> _downloadAndSave(BuildContext context) async {
    try {
      // Step 1: Permission check
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      // Step 2: Download file as bytes
      await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Preview"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadAndSave(context),
          ),
        ],
      ),
      body: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const CircularProgressIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            return const Text("Failed to load image");
          },
        ),
      ),
    );
  }
}
