import 'package:get/get.dart';
import 'package:lokkha/features/exam/exam.dart';

import '../controllers/see_all_items_controller.dart';

class SeeAllItemsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ExamRemoteDataSource>()) {
      Get.lazyPut<ExamRemoteDataSource>(() => ExamRemoteDataSourceImpl());
    }
    if (!Get.isRegistered<ExamRepository>()) {
      Get.lazyPut<ExamRepository>(
        () => ExamRepositoryImpl(
          remoteDataSource: Get.find<ExamRemoteDataSource>(),
        ),
      );
    }
    if (!Get.isRegistered<GetUserExamsUseCase>()) {
      Get.lazyPut<GetUserExamsUseCase>(
        () => GetUserExamsUseCase(repository: Get.find<ExamRepository>()),
      );
    }
    Get.lazyPut<SeeAllItemsController>(
      () => SeeAllItemsController(
        getUserExamsUseCase: Get.find<GetUserExamsUseCase>(),
      ),
    );
  }
}

