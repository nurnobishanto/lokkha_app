// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/packages/presentation/views/payment_webview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class TestWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return TestPlatformWebViewController(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return TestPlatformNavigationDelegate(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return TestPlatformWebViewWidget(params);
  }
}

class TestPlatformWebViewController extends PlatformWebViewController {
  TestPlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<void> runJavaScript(String javaScript) async {}
}

class TestPlatformNavigationDelegate extends PlatformNavigationDelegate {
  TestPlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}
}

class TestPlatformWebViewWidget extends PlatformWebViewWidget {
  TestPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(key: Key('mock_webview'));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    WebViewPlatform.instance = TestWebViewPlatform();
  });

  group('PaymentWebView Widget Tests', () {
    testWidgets('PaymentWebView renders AppBar with back button and title',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentWebView(url: 'https://lokkha.com/payment/test'),
        ),
      );

      // Verify Title
      expect(find.text('পেমেন্ট করুন'), findsOneWidget);

      // Verify Leading Back Button
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Tap Leading Back Button -> triggers exit confirmation dialog
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Verify Dialog appears
      expect(find.text('পেমেন্ট বাতিল করতে চান?'), findsOneWidget);
      expect(find.text('না, অপেক্ষা করুন'), findsOneWidget);
      expect(find.text('হ্যাঁ, বের হন'), findsOneWidget);

      // Tap 'না, অপেক্ষা করুন' -> dialog closes
      await tester.tap(find.text('না, অপেক্ষা করুন'));
      await tester.pumpAndSettle();

      expect(find.text('পেমেন্ট বাতিল করতে চান?'), findsNothing);
    });

    testWidgets('PaymentWebView exits when user confirms exit in dialog',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaymentWebView(
                        url: 'https://lokkha.com/payment/test',
                      ),
                    ),
                  );
                },
                child: const Text('Open Payment'),
              ),
            ),
          ),
        ),
      );

      // Push PaymentWebView
      await tester.tap(find.text('Open Payment'));
      await tester.pumpAndSettle();

      expect(find.text('পেমেন্ট করুন'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Tap 'হ্যাঁ, বের হন'
      await tester.tap(find.text('হ্যাঁ, বের হন'));
      await tester.pumpAndSettle();

      // PaymentWebView is popped and user is back on the app screen
      expect(find.text('Open Payment'), findsOneWidget);
      expect(find.text('পেমেন্ট করুন'), findsNothing);
    });
  });
}
