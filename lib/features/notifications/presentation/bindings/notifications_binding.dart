import 'package:get/get.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources
    Get.lazyPut<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(),
    );

    // Repository
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: Get.find<NotificationRemoteDataSource>(),
      ),
    );

    // Use cases
    Get.lazyPut<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(Get.find<NotificationRepository>()),
    );

    // Controller
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(
        getNotificationsUseCase: Get.find<GetNotificationsUseCase>(),
        markNotificationReadUseCase: Get.find<MarkNotificationReadUseCase>(),
      ),
    );
  }
}
