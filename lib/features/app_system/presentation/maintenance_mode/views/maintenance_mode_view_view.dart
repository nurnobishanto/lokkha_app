import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/routes/routes.dart';
import '../controllers/maintenance_mode_view_controller.dart';

class MaintenanceModeView extends GetView<MaintenanceModeController> {
  const MaintenanceModeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetImagePaths.seamlessImg),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    "Our App is currently under maintenance. We apologize for any inconvenience and appreciate your patience. We'll be back soon!",
                    style: TextStyle(
                      fontSize: 17,
                      color: LightThemeColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // SizedBox(
                //   height: 400,
                //   width: 300,
                //   child: Lottie.asset(AppImages.maintenanceModeJson),
                // ),
                const SizedBox(height: 30.00),
                Row(
                  children: [
                    Expanded(
                      child: CustomActionButton(
                        text: "Refresh",
                        onPressed: () {
                          Get.offAllNamed(Routes.SPLASH);
                        },
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: CustomActionButton(
                        btnBackgroundColor: Colors.red,
                        text: "Exit",
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
