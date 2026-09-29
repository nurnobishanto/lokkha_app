import 'package:get/get.dart';

import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/blog/blog.dart';
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
