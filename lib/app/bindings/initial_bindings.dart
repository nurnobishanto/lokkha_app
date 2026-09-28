import 'package:get/get.dart';
import 'package:lokkha/app/modules/nav_bar_views/home/controllers/home_controller.dart';
import 'package:lokkha/app/services/app_lifecycle_service.dart';
import 'package:lokkha/app/services/premium_entitlement_service.dart';
import 'package:lokkha/config/theme/theme_controller.dart';

import '../../my_app/controllers/my_app_controller.dart';
import '../modules/navbar/controllers/navbar_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(MyAppController(), permanent: true);
    Get.put(HomeController(), permanent: true);

    Get.put(NavbarController(), permanent: true);

    Get.put(PremiumEntitlementService(), permanent: true);
    Get.put(AppLifecycleService(), permanent: true);
  }
}
