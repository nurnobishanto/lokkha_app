import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/vocabulary_controller.dart';

class VocabularyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VocabularyController>(
      () => VocabularyController(),
    );
  }
}
