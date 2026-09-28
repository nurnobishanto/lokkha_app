import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/splash/views/splash_view.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lokkha/app/services/premium_entitlement_service.dart';

import '../../../services/auth_service.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key, required this.url});
  final String url;

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController webViewController;
  double _progress = 0;
  bool _isNavigating = false;
  @override
  void initState() {
    debugPrint("Payment url page:${widget.url}");
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Convert 0–100 → 0.0–1.0
            setState(() => _progress = progress / 100);
          },
          onPageStarted: (String url) {
            setState(() => _progress = 0);
          },
          onPageFinished: (String url) {
            setState(() => _progress = 1);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() => _progress = 1);
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (_isNavigating) {
              return NavigationDecision.prevent;
            }

            if (request.url.contains('order-details')) {
              _isNavigating = true;

              await Get.find<PremiumEntitlementService>()
                  .refreshAfterPurchase();

              AuthService().authCheck();
              //Get.offAll(OrderDetailsScreen(url: request.url));
              Get.to(SplashView());
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          // onNavigationRequest: (NavigationRequest request) {
          //   if (request.url.contains('order-details')) {
          //     Get.find<PremiumEntitlementService>().refreshAfterPurchase();
          //     Get.off(OrderDetailsScreen(url: request.url));
          //   } else if (request.url.startsWith("https://youtube.com")) {
          //     return NavigationDecision.prevent;
          //   }
          //   return NavigationDecision.navigate;
          // },
        ),
      )
      ..loadRequest(Uri.parse(widget.url.toString()));
    if (kDebugMode) {
      print("Load Url make :::${widget.url}");
    }
  }

  @override
  void dispose() {
    debugPrint("PaymentWebView disposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "পেমেন্ট করুন",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: LightThemeColors.primaryColor,
          bottom: _progress < 1
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3.0),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
        ),
        body: SafeArea(child: WebViewWidget(controller: webViewController)),
      ),
    );
  }
}
