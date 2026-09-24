import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'app/data/local/my_shared_pref.dart';
import 'app/data/network/api_client.dart';
import 'app/helper/global.dart';
import 'my_app/views/my_app_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init GetStorage
  await GetStorage.init();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(".env load failed: $e");
  }

  // Init ApiClient
  ApiClient.init();

  // Init SharedPreferences safely
  try {
    await MySharedPref.init();
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

  runApp(const MyApp());
}
