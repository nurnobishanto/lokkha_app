import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/auth_views/auth_gateway/views/auth_gateway_view.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helper/global.dart';

class MessengerRedirectScreen extends StatefulWidget {
  const MessengerRedirectScreen({super.key});

  @override
  State<MessengerRedirectScreen> createState() =>
      _MessengerRedirectScreenState();
}

class _MessengerRedirectScreenState extends State<MessengerRedirectScreen> {
  @override
  void initState() {
    super.initState();
    
    // Use 'ever' worker to react to login state changes
    ever(isLoggedIn, (bool loggedIn) {
      if (loggedIn && mounted) {
        // If we are currently showing this tab and the user just logged in, redirect
        _redirectToMessenger();
      }
    });

    // Initial check
    if (isLoggedIn.value) {
      _redirectToMessenger();
    }
  }

  Future<void> _redirectToMessenger() async {
    const messengerUrl = 'https://m.me/lokkhabd';
    final uri = Uri.parse(messengerUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Messenger could not be launched");
      }
    } catch (e) {
      debugPrint("Error launching Messenger: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // If not logged in, show AuthGatewayView directly within the tab
      if (!isLoggedIn.value) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Messenger Support",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: LightThemeColors.primaryColor,
            automaticallyImplyLeading: false,
          ),
          body: const AuthGatewayView(),
        );
      }

      // If logged in, show the redirecting UI
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Messenger Support",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: LightThemeColors.primaryColor,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: context.scaffoldBg,
        body: Center(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    "assets/lottie/messenger.json",
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.chat, size: 100, color: Colors.blue);
                    },
                  ),
                ),
                Text(
                  "Redirecting To Messenger",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please wait...",
                  style: TextStyle(
                    color: context.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _redirectToMessenger,
                  icon: const Icon(Icons.open_in_new, color: Colors.white),
                  label: const Text("Open Messenger Now", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LightThemeColors.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
