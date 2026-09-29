import 'package:get/get.dart';

import '../controllers/sponsor_ads_controller.dart';

class SponsorAdsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SponsorAdsController>(
      () => SponsorAdsController(),
    );
  }
}
