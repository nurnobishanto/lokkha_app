import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lokkha/core/network/endpoints.dart';

class BaseWebView extends StatefulWidget {
  final String title;
  final String url;

  const BaseWebView({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<BaseWebView> createState() => _BaseWebViewState();
}

class _BaseWebViewState extends State<BaseWebView> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    String targetUrl = widget.url.trim();
    if (targetUrl.startsWith('/')) {
      targetUrl = '${Endpoints.baseUrl}$targetUrl';
    } else if (!targetUrl.startsWith('http://') &&
        !targetUrl.startsWith('https://')) {
      targetUrl = 'https://$targetUrl';
    }
    _controller = WebViewController();
    _controller.loadRequest(Uri.parse(targetUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
