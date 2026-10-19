import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lokkha/app/router/router.dart';

enum ExamWebViewMode {
  start,
  result,
  read,
  generic,
}

class WebExamView extends StatefulWidget {
  final String title;
  final String url;
  final Map<String, dynamic>? body;
  final int? examId;
  final ExamWebViewMode mode;
  final bool? isExamRunning;

  const WebExamView({
    super.key,
    required this.title,
    required this.url,
    this.body,
    this.examId,
    this.mode = ExamWebViewMode.generic,
    this.isExamRunning,
  });

  @override
  State<WebExamView> createState() => _WebExamViewState();
}

class _WebExamViewState extends State<WebExamView> {
  late WebViewController _controller;
  bool isLoading = true;
  double loadingProgress = 0.0;
  String currentUrl = '';
  bool hasError = false;

  @override
  void initState() {
    super.initState();

    final token = MySharedPref.getUserToken();

    if (token.isEmpty && widget.mode == ExamWebViewMode.start) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushNamed(Routes.authGateway);
      });
    }

    final Map<String, String> headers = {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'LokkhaMobileBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleBridgeMessage(message.message);
        },
      )
      ..addJavaScriptChannel(
        'MobileBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleBridgeMessage(message.message);
        },
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleBridgeMessage(message.message);
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          if (!mounted) return;
          setState(() {
            loadingProgress = progress / 100.0;
          });
        },
        onPageStarted: (String url) {
          if (!mounted) return;
          setState(() {
            isLoading = true;
            hasError = false;
            currentUrl = url;
          });
          _handleUrlInterception(url);
        },
        onPageFinished: (String url) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            currentUrl = url;
          });
          debugPrint("[WebExamView] Page finished: $url");
        },
        onWebResourceError: (WebResourceError error) {
          if (!mounted) return;
          log("[WebExamView] Web error: ${error.description}");
          setState(() {
            isLoading = false;
            // Only set fatal error if the main frame failed
            if (error.isForMainFrame ?? true) {
              hasError = true;
            }
          });
        },
        onNavigationRequest: (NavigationRequest request) {
          final url = request.url.toLowerCase();
          if (url.contains('goback') || url.contains('return-to-app')) {
            if (mounted) Navigator.of(context).pop();
            return NavigationDecision.prevent;
          }
          if (url.contains('packages') && !url.contains('api/v1/packages')) {
            if (mounted) context.push(Routes.packages);
            return NavigationDecision.prevent;
          }
          if (url.contains('pdf') || url.endsWith('.pdf')) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PdfViewerScreen(title: "ডাউনলোড", file: request.url),
              ),
            );
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));

    _loadTargetUrl(token, headers);
  }

  void _loadTargetUrl(String token, Map<String, String> headers) {
    try {
      final uri = Uri.parse(widget.url);
      final query = Map<String, dynamic>.from(uri.queryParameters);

      // Injects token if not present and available
      if (token.isNotEmpty && !query.containsKey('token')) {
        query['token'] = token;
      }

      if (widget.body != null) {
        query.addAll(widget.body!);
      }

      final Map<String, String> stringQueryParams = encodeQueryParams(query);
      final Uri finalUri = uri.replace(queryParameters: stringQueryParams);

      _controller.loadRequest(
        finalUri,
        headers: headers,
      );
    } catch (e) {
      log("[WebExamView] Error loading URL: $e");
    }
  }

  void _handleBridgeMessage(String raw) {
    log("[WebExamView] JS Bridge message: $raw");
    try {
      if (raw == 'RETURN_TO_APP' || raw == 'CLOSE_EXAM' || raw == 'FINISH') {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      if (raw == 'OPEN_PACKAGES') {
        if (mounted) context.push(Routes.packages);
        return;
      }

      // JSON payload support
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final action = decoded['action']?.toString().toUpperCase();
        if (action == 'RETURN_TO_APP' || action == 'CLOSE_EXAM') {
          if (mounted) Navigator.of(context).pop();
        } else if (action == 'OPEN_PACKAGES') {
          if (mounted) context.push(Routes.packages);
        } else if (action == 'EXAM_SUBMITTED') {
          final resultUrl = decoded['result_url']?.toString();
          if (resultUrl != null && resultUrl.isNotEmpty) {
            _controller.loadRequest(Uri.parse(resultUrl));
          }
        }
      }
    } catch (_) {
      if (raw.contains('RETURN_TO_APP') || raw.contains('goback')) {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  void _handleUrlInterception(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('goback') || lower.contains('return-to-app')) {
      Navigator.of(context).pop();
    } else if (lower.contains('packages') && !lower.contains('api/v1/packages')) {
      context.push(Routes.packages);
    }
  }

  Future<bool?> _showCancelExamDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "পরীক্ষা বাতিল",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "আপনি কি নিশ্চিত যে পরীক্ষা থেকে বের হতে চান?\nআপনার উত্তরপত্র স্বয়ংক্রিয়ভাবে সার্ভারে সংরক্ষিত রয়েছে।",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text("না, চালিয়ে যান"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text("হ্যাঁ, বের হন"),
          ),
        ],
      ),
    );
  }

  bool _isExamRunning() {
    if (widget.isExamRunning == true) return true;
    if (widget.mode == ExamWebViewMode.start) return true;
    return currentUrl.contains('/webview/start') || currentUrl.contains('web-exam-start');
  }

  @override
  Widget build(BuildContext context) {
    final isRunner = _isExamRunning();

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF006A4E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () async {
            if (isRunner) {
              final shouldExit = await _showCancelExamDialog();
              if (shouldExit != true) return;
            }
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (!hasError) WebViewWidget(controller: _controller),
            if (isLoading)
              LinearProgressIndicator(
                value: loadingProgress > 0 ? loadingProgress : null,
                backgroundColor: Colors.transparent,
                color: const Color(0xFF059669),
                minHeight: 3,
              ),
            if (hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        "পৃষ্ঠাটি লোড করা সম্ভব হয়নি",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "আপনার ইন্টারনেট সংযোগটি পরীক্ষা করুন এবং পুনরায় চেষ্টা করুন।",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006A4E),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            hasError = false;
                            isLoading = true;
                          });
                          _controller.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("পুনরায় চেষ্টা করুন"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: currentUrl.contains('pdf')
          ? FloatingActionButton.extended(
              onPressed: () => launchUrlString(currentUrl),
              icon: const Icon(Icons.download, color: Colors.white, size: 20),
              label: const Text(
                'ডাউনলোড',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: const Color(0xFF006A4E),
            )
          : null,
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
