import 'package:get/get.dart';

import '../../premium_packages/controllers/premium_packages_controller.dart';
import '../../profile_module/profile/controllers/profile_controller.dart';
import '../../exam_category/controllers/exam_category_controller.dart';
import '../../nav_bar_views/blog/controllers/blog_controller.dart';
import '../controllers/navbar_controller.dart';

class NavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavbarController>(
      () => NavbarController(),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
    Get.lazyPut<PremiumPackagesController>(
      () => PremiumPackagesController(),
    );
    Get.lazyPut<ExamCategoryController>(
      () => ExamCategoryController(),
    );
    Get.lazyPut<BlogController>(
      () => BlogController(),
    );
  }
}
