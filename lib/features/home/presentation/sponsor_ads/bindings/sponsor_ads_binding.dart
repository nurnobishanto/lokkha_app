import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/sponsor_ads_controller.dart';

class SponsorAdsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SponsorAdsController>(
      () => SponsorAdsController(),
    );
  }
}
