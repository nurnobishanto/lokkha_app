import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import '../../data/models/notification_model.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

class NotificationsController extends GetxController {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationsController({
    GetNotificationsUseCase? getNotificationsUseCase,
    MarkNotificationReadUseCase? markNotificationReadUseCase,
  })  : getNotificationsUseCase =
            getNotificationsUseCase ?? Get.find<GetNotificationsUseCase>(),
        markNotificationReadUseCase =
            markNotificationReadUseCase ?? Get.find<MarkNotificationReadUseCase>();

  Rx<NotificationModel> model = const NotificationModel().obs;
  RxBool isLoading = true.obs;
  String? deviceId;

  Future<void> fetchNotifications() async {
    if (kDebugMode) print("fetchNotifications API Called via Clean Architecture...");
    isLoading.value = true;
    update();

    try {
      final result = await getNotificationsUseCase(deviceId: deviceId);
      if (result is NotificationModel) {
        model.value = result;
      } else {
        model.value = NotificationModel(
          status: result.status,
          unreadCount: result.unreadCount,
          notifications: result.notifications,
        );
      }
      unReadNotificationCount.value = model.value.unreadCount ?? 0;
      isLoading.value = false;
    } catch (err) {
      isLoading.value = false;
      if (kDebugMode) print("Error fetching Notifications: $err");
      CustomSnackBar.showCustomToast(
        title: "Something Went Wrong!",
        message: err.toString(),
      );
    }
  }

  Future<void> markAsRead(int notificationId, bool isRead) async {
    try {
      final success = await markNotificationReadUseCase(
        notificationId: notificationId,
        deviceId: deviceId,
        isRead: isRead,
      );
      if (success) {
        debugPrint("Successfully marked notification as read");
        await fetchNotifications();
        model.refresh();
      } else {
        isLoading.value = false;
        CustomSnackBar.showCustomToast(
          title: "Something Went Wrong!",
          message: "Failed to mark notification as read",
        );
      }
    } catch (err) {
      isLoading.value = false;
      if (kDebugMode) print("Error marking Notification read: $err");
    }
  }

  @override
  void onInit() async {
    deviceId = await getDeviceId();
    debugPrint("Device ID: $deviceId");
    fetchNotifications();
    super.onInit();
  }
}
