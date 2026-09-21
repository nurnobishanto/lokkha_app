import 'package:get/get.dart';
import '../controllers/blog_detail_controller.dart';

class BlogDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlogDetailController>(
      () => BlogDetailController(),
    );
  }
}
