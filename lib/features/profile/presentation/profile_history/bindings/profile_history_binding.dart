import 'package:lokkha/core/compat/get_compat.dart';
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
