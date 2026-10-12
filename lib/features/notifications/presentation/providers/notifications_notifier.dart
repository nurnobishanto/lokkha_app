import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

class NotificationsState {
  final bool isLoading;
  final NotificationModel model;

  const NotificationsState({
    this.isLoading = true,
    this.model = const NotificationModel(),
  });

  NotificationsState copyWith({
    bool? isLoading,
    NotificationModel? model,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      model: model ?? this.model,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  late final GetNotificationsUseCase _getNotificationsUseCase;
  late final MarkNotificationReadUseCase _markNotificationReadUseCase;
  String? deviceId;

  @override
  NotificationsState build() {
    final remoteDataSource = NotificationRemoteDataSourceImpl();
    final repository =
        NotificationRepositoryImpl(remoteDataSource: remoteDataSource);
    _getNotificationsUseCase = GetNotificationsUseCase(repository);
    _markNotificationReadUseCase = MarkNotificationReadUseCase(repository);

    Future.microtask(() async {
      deviceId = await getDeviceId();
      fetchNotifications();
    });

    return const NotificationsState();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _getNotificationsUseCase(deviceId: deviceId);
      final NotificationModel updatedModel;
      if (result is NotificationModel) {
        updatedModel = result;
      } else {
        updatedModel = NotificationModel(
          status: result.status,
          unreadCount: result.unreadCount,
          notifications: result.notifications,
        );
      }
      unReadNotificationCount.value = updatedModel.unreadCount ?? 0;
      state = state.copyWith(model: updatedModel, isLoading: false);
    } catch (err) {
      state = state.copyWith(isLoading: false);
      if (kDebugMode) print("Error fetching Notifications: $err");
      CustomSnackBar.showCustomToast(
        title: "Something Went Wrong!",
        message: err.toString(),
      );
    }
  }

  Future<void> markAsRead(int notificationId, bool isRead) async {
    try {
      final success = await _markNotificationReadUseCase(
        notificationId: notificationId,
        deviceId: deviceId,
        isRead: isRead,
      );
      if (success) {
        debugPrint("Successfully marked notification as read");
        await fetchNotifications();
      } else {
        CustomSnackBar.showCustomToast(
          title: "Something Went Wrong!",
          message: "Failed to mark notification as read",
        );
      }
    } catch (err) {
      if (kDebugMode) print("Error marking Notification read: $err");
    }
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
