import 'package:get/get.dart';
import 'package:lokkha/features/profile/profile.dart';

class ProfileHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetExamHistoryUseCase>(
      () => GetExamHistoryUseCase(repository: ProfileRepository()),
    );
    Get.lazyPut<ProfileHistoryController>(
      () => ProfileHistoryController(
        getExamHistoryUseCase: Get.isRegistered<GetExamHistoryUseCase>()
            ? Get.find<GetExamHistoryUseCase>()
            : GetExamHistoryUseCase(),
      ),
    );
  }
}
