import 'package:get/get.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/home/home.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Required controllers
    Get.lazyPut<LatestContestController>(() => LatestContestController());
    Get.lazyPut<ExamCategoryController>(() => ExamCategoryController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SeeAllItemsController>(() => SeeAllItemsController());
  }
}
