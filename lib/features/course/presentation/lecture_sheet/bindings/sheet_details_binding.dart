import 'package:lokkha/core/compat/get_compat.dart';
import 'package:lokkha/features/course/course.dart';

class SheetDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SheetDetailsController>(
      () => SheetDetailsController(),
    );
  }
}
