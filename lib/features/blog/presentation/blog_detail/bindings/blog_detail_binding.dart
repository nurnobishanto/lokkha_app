import 'package:lokkha/core/compat/get_compat.dart';
import '../controllers/blog_detail_controller.dart';

class BlogDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlogDetailController>(
      () => BlogDetailController(),
    );
  }
}
