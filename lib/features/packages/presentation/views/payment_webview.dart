import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lokkha/features/app_system/app_system.dart';
import 'package:lokkha/core/core.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  bool _isPaymentFinished = false;

  @override
  void initState() {
    debugPrint("Payment url page: ${widget.url}");
    super.initState();
    _checkIfPaymentFinished(widget.url);

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'LokkhaApp',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint("LokkhaApp JS channel message: ${message.message}");
          if (message.message == 'payment_finished') {
            _isPaymentFinished = true;
          } else {
            _returnToApp();
          }
        },
      )
      ..addJavaScriptChannel(
        'FlutterPayment',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint("FlutterPayment JS channel message: ${message.message}");
          if (message.message == 'payment_finished') {
            _isPaymentFinished = true;
          } else {
            _returnToApp();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() => _progress = progress / 100);
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => _progress = 0);
            }
            _checkIfPaymentFinished(url);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _progress = 1);
            }
            _checkIfPaymentFinished(url);
            _injectBackHandlers();
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() => _progress = 1);
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (_isNavigating) {
              return NavigationDecision.prevent;
            }

            final url = request.url;
            final lowerUrl = url.toLowerCase();
            debugPrint("Payment navigation request: $url");

            // 1. Success case: order details or successful completion callback
            if (lowerUrl.contains('order-details') ||
                lowerUrl.contains('/payment/success') ||
                lowerUrl.contains('status=success') ||
                lowerUrl.contains('payment_status=success')) {
              _isNavigating = true;

              try {
                final entitlement = PremiumEntitlementService.to;
                await entitlement.refreshAfterPurchase();
              } catch (e) {
                debugPrint("Entitlement refresh error: $e");
              }

              AuthService().authCheck();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashView()),
                  (route) => false,
                );
              }
              return NavigationDecision.prevent;
            }

            // 2. Custom app deep link schemes (lokkha://, app://, intent://, etc.)
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              debugPrint("Custom app scheme detected, returning to app: $url");
              _returnToApp();
              return NavigationDecision.prevent;
            }

            // 3. Web endpoints that represent returning to app home or pages
            final uri = Uri.tryParse(url);
            if (uri != null) {
              final path = uri.path.toLowerCase();
              final isHostLokkha = uri.host.contains('lokkha.com');

              final isWebReturn = isHostLokkha &&
                  (path == '' ||
                      path == '/' ||
                      path == '/home' ||
                      path == '/packages' ||
                      path == '/my-packages' ||
                      path == '/my-orders' ||
                      path == '/orders' ||
                      path == '/courses' ||
                      path == '/dashboard');

              final isExplicitBackUrl = lowerUrl.contains('back-to-app') ||
                  lowerUrl.contains('back_to_app') ||
                  lowerUrl.contains('return-to-app') ||
                  lowerUrl.contains('app-back') ||
                  lowerUrl.contains('app/back');

              if (isWebReturn || isExplicitBackUrl) {
                debugPrint("App destination URL intercepted, returning to app: $url");
                _returnToApp();
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url.toString()));

    if (kDebugMode) {
      print("Load Url make :::${widget.url}");
    }
  }

  void _checkIfPaymentFinished(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('cancel') ||
        lower.contains('failed') ||
        lower.contains('failure') ||
        lower.contains('error') ||
        lower.contains('success')) {
      _isPaymentFinished = true;
    }
  }

  Future<void> _injectBackHandlers() async {
    try {
      await webViewController.runJavaScript('''
        (function() {
          try {
            // Override window.close
            window.close = function() {
              try {
                if (window.LokkhaApp) {
                  window.LokkhaApp.postMessage('close');
                } else if (window.FlutterPayment) {
                  window.FlutterPayment.postMessage('close');
                }
              } catch(e) {}
            };

            // Detect if page shows payment canceled or failed
            if (document.body) {
              const bodyText = document.body.innerText || '';
              if (bodyText.includes('PAYMENT CANCELED') || 
                  bodyText.includes('পেমেন্ট বাতিল') || 
                  bodyText.includes('PAYMENT FAILED')) {
                if (window.LokkhaApp) {
                  window.LokkhaApp.postMessage('payment_finished');
                }
              }
            }

            // Function to attach click listeners to Back to App buttons
            function attachHandlers() {
              const elements = document.querySelectorAll('a, button, input[type="button"], [role="button"], div, span');
              elements.forEach(function(el) {
                if (el.__lokkhaHandled) return;

                const text = (el.innerText || el.textContent || '').trim().toLowerCase();
                const isBackText = text.includes('অ্যাপে ফিরে যান') || 
                                   text.includes('back to app') || 
                                   text.includes('ফিরে যান');

                const href = (el.getAttribute && el.getAttribute('href')) ? el.getAttribute('href') : '';
                const isBackHref = href.startsWith('lokkha://') ||
                                   href.startsWith('app://') ||
                                   href === '#' ||
                                   href.includes('javascript:window.close()') ||
                                   href.includes('back') ||
                                   href.includes('close');

                if (isBackText || (href && isBackHref && !href.startsWith('http') && !href.includes('payment'))) {
                  el.__lokkhaHandled = true;
                  el.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    if (window.LokkhaApp) {
                      window.LokkhaApp.postMessage('back_to_app');
                    } else if (window.FlutterPayment) {
                      window.FlutterPayment.postMessage('back_to_app');
                    }
                  }, true);
                }
              });
            }

            attachHandlers();

            // Observe dynamic DOM insertions
            if (window.MutationObserver) {
              const observer = new MutationObserver(function() {
                attachHandlers();
              });
              observer.observe(document.body, { childList: true, subtree: true });
            }
          } catch(e) {
            console.error('Lokkha back handler injection failed', e);
          }
        })();
      ''');
    } catch (e) {
      debugPrint("Error injecting back handlers: $e");
    }
  }

  void _returnToApp() {
    if (_isNavigating) return;
    _isNavigating = true;

    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashView()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleBack() async {
    if (_isNavigating) return;

    if (_isPaymentFinished) {
      _returnToApp();
      return;
    }

    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "পেমেন্ট বাতিল করতে চান?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          "আপনি কি নিশ্চিত যে আপনি পেমেন্ট প্রক্রিয়া থেকে বের হতে চান?",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("না, অপেক্ষা করুন"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LightThemeColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("হ্যাঁ, বের হন"),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      _returnToApp();
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
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _handleBack,
            tooltip: "ফিরে যান",
          ),
          title: const Text(
            "পেমেন্ট করুন",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        body: SafeArea(child: WebViewWidget(controller: webViewController)),
      ),
    );
  }
}
