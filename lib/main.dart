import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(".env load failed: $e");
  }


  // Init SharedPreferences safely
  try {
    await MySharedPref.init();
    await AppStorageCache.wipeAllDataCaches();
  } catch (e) {
    debugPrint("SharedPreferences init failed: $e");
  }

  // Init OneSignal safely
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
  if (oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(oneSignalAppId);
      OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint("OneSignal init failed: $e");
    }
  } else {
    debugPrint("ONESIGNAL_APP_ID not found in .env");
  }

  // Fetch app version before starting
  try {
    await fetchAppVersion();
  } catch (e) {
    debugPrint("Fetch app version failed: $e");
  }

  // Initialize core app services
  try {
    AppLifecycleService.init();
  } catch (e) {
    debugPrint("Services setup failed: $e");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
