import 'package:get/get.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/core/services/app_lifecycle_service.dart';
import 'package:lokkha/core/services/premium_entitlement_service.dart';
import 'package:lokkha/core/theme/theme_controller.dart';
import 'package:lokkha/my_app/controllers/my_app_controller.dart';
import 'package:lokkha/features/navigation/navigation.dart';

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
