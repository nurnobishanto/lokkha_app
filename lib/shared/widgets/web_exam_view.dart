import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lokkha/app/router/router.dart';

class WebExamView extends StatefulWidget {
  final String title;
  final String url;
  final Map<String, dynamic>? body;

  const WebExamView({
    super.key,
    required this.title,
    required this.url,
    this.body,
  });

  @override
  State<WebExamView> createState() => _WebExamViewState();
}

class _WebExamViewState extends State<WebExamView> {
  late WebViewController _controller;
  bool isLoading = false;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();

    String? token = MySharedPref.getUserToken();

    if (token == null || token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushNamed(Routes.authGateway);
      });
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          log("PROGRESS $progress%");
        },
        onPageStarted: (String url) {
          if (!mounted) return;
          setState(() {
            isLoading = true;
            currentUrl = url;
          });
          if (url.contains('packages')) {
            context.pushNamed(Routes.packages);
          } else if (url.contains('goback')) {
            Navigator.of(context).pop();
          }
        },
        onPageFinished: (String url) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            currentUrl = url;
          });
          if (url.contains('packages')) {
            _controller.goBack();
          } else if (url.contains('goback')) {
            _controller.goBack();
          } else if (url.contains('login')) {
            _controller.goBack();
          } else if (url.contains('pdf')) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PdfViewerScreen(title: "Download", file: url),
              ),
            );
            _controller.goBack();
          }
          debugPrint("PROGRESS $url");
        },
        onWebResourceError: (error) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        },
      ));

    final Map<String, dynamic> dataWithToken = {
      'token': token,
      ...?widget.body,
    };

    final Map<String, String> queryParams = encodeQueryParams(dataWithToken);
    final Uri finalUri =
        Uri.parse(widget.url).replace(queryParameters: queryParams);

    _controller.loadRequest(
      finalUri,
      headers: headers,
    );
  }

  Future<bool?> _showCancelExamDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Cancel Exam"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "আপনি কি নিশ্চিত যে পরীক্ষা বাতিল করতে চান?\nআপনার অগ্রগতি সংরক্ষিত হবে না।",
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomActionButton(
                    text: 'না',
                    onPressed: () => Navigator.of(dialogCtx).pop(false),
                    btnBackgroundColor: Colors.grey,
                    borderColor: Colors.transparent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomActionButton(
                    text: 'হ্যাঁ, বাতিল করুন',
                    onPressed: () => Navigator.of(dialogCtx).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (currentUrl.endsWith('start')) {
              bool? shouldExit = await _showCancelExamDialog();
              if (shouldExit != true) {
                return;
              }
            }
            if (currentUrl.contains('submit') ||
                currentUrl.contains('start') ||
                currentUrl.contains('result')) {
              if (context.mounted) Navigator.of(context).pop();
            } else {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              } else {
                if (context.mounted) Navigator.of(context).pop();
              }
            }
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.6),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: currentUrl.contains('pdf')
          ? FloatingActionButton.extended(
              onPressed: () {
                launchUrlString(currentUrl);
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
            )
          : const SizedBox.shrink(),
    );
  }
}

Map<String, String> encodeQueryParams(Map<String, dynamic> data) {
  final Map<String, String> result = {};

  data.forEach((key, value) {
    if (value == null) return;

    if (value is String || value is num || value is bool) {
      result[key] = value.toString();
    } else {
      result[key] = jsonEncode(value);
    }
  });

  return result;
}
