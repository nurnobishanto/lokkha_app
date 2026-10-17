import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/di/notification_provider.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import '../../data/models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

class NotificationsState {
  final bool isLoading;
  final bool isMarkingAllRead;
  final NotificationModel model;
  final String? errorMessage;

  const NotificationsState({
    this.isLoading = true,
    this.isMarkingAllRead = false,
    this.model = const NotificationModel(),
    this.errorMessage,
  });

  NotificationsState copyWith({
    bool? isLoading,
    bool? isMarkingAllRead,
    NotificationModel? model,
    String? errorMessage,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
      model: model ?? this.model,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  GetNotificationsUseCase? _getNotificationsUseCase;
  MarkNotificationReadUseCase? _markNotificationReadUseCase;
  MarkAllNotificationsReadUseCase? _markAllNotificationsReadUseCase;
  String? deviceId;

  NotificationsNotifier({
    GetNotificationsUseCase? getNotificationsUseCase,
    MarkNotificationReadUseCase? markNotificationReadUseCase,
    MarkAllNotificationsReadUseCase? markAllNotificationsReadUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markNotificationReadUseCase = markNotificationReadUseCase,
        _markAllNotificationsReadUseCase = markAllNotificationsReadUseCase;

  @override
  NotificationsState build() {
    _getNotificationsUseCase ??= ref.watch(getNotificationsUseCaseProvider);
    _markNotificationReadUseCase ??=
        ref.watch(markNotificationReadUseCaseProvider);
    _markAllNotificationsReadUseCase ??=
        ref.watch(markAllNotificationsReadUseCaseProvider);

    Future.microtask(() async {
      if (!ref.mounted) return;
      deviceId = await getDeviceId();
      if (!ref.mounted) return;
      fetchNotifications();
    });

    return const NotificationsState();
  }

  Future<void> fetchNotifications() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getNotificationsUseCase!(deviceId: deviceId);
      if (!ref.mounted) return;

      final NotificationModel updatedModel;
      if (result is NotificationModel) {
        updatedModel = result;
      } else {
        updatedModel = NotificationModel(
          status: result.status,
          message: result.message,
          unreadCount: result.unreadCount,
          notifications: result.notifications,
        );
      }
      unReadNotificationCount.value = updatedModel.unreadCount ?? 0;
      state = state.copyWith(model: updatedModel, isLoading: false);
    } catch (err) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: err.toString());
      if (kDebugMode) print("Error fetching Notifications: $err");
      CustomSnackBar.showCustomToast(
        title: "Something Went Wrong!",
        message: err.toString(),
      );
    }
  }

  Future<void> markAsRead(int notificationId, [bool isRead = true]) async {
    final currentList = state.model.notifications;
    final index = currentList.indexWhere((n) => n.id == notificationId);
    final wasUnread = index != -1 && currentList[index].isRead != true;

    // 1. Optimistic UI update
    if (wasUnread) {
      final updatedList = List<NotificationEntity>.from(currentList);
      updatedList[index] = updatedList[index].copyWith(isRead: true);
      final newUnreadCount =
          (state.model.unreadCount != null && state.model.unreadCount! > 0)
              ? state.model.unreadCount! - 1
              : 0;
      unReadNotificationCount.value = newUnreadCount;
      if (ref.mounted) {
        state = state.copyWith(
          model: state.model.copyWith(
            unreadCount: newUnreadCount,
            notifications: updatedList,
          ),
        );
      }
    }

    // 2. Network call to v1 endpoint
    try {
      final success = await _markNotificationReadUseCase!(
        notificationId: notificationId,
        deviceId: deviceId,
        isRead: isRead,
      );
      if (!ref.mounted) return;
      if (!success && wasUnread) {
        await fetchNotifications();
      }
    } catch (err) {
      if (kDebugMode) print("Error marking Notification read: $err");
      if (!ref.mounted) return;
      if (wasUnread) {
        await fetchNotifications();
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (state.model.notifications.isEmpty) return;
    final currentUnreadCount = state.model.unreadCount ?? 0;
    final previousList = state.model.notifications;

    // 1. Optimistic UI update
    final updatedList =
        previousList.map((n) => n.copyWith(isRead: true)).toList();
    unReadNotificationCount.value = 0;
    state = state.copyWith(
      isMarkingAllRead: true,
      model: state.model.copyWith(
        unreadCount: 0,
        notifications: updatedList,
      ),
    );

    // 2. Network call to v1 read-all endpoint
    try {
      final success =
          await _markAllNotificationsReadUseCase!(deviceId: deviceId);
      if (!ref.mounted) return;

      state = state.copyWith(isMarkingAllRead: false);
      if (success) {
        CustomSnackBar.showCustomToast(
          title: "সফল",
          message: "সকল নোটিফিকেশন পড়া হয়েছে হিসেবে চিহ্নিত করা হয়েছে।",
        );
      } else {
        // Revert on failure
        unReadNotificationCount.value = currentUnreadCount;
        state = state.copyWith(
          model: state.model.copyWith(
            unreadCount: currentUnreadCount,
            notifications: previousList,
          ),
        );
        CustomSnackBar.showCustomToast(
          title: "Something Went Wrong!",
          message: "Failed to mark all notifications as read",
        );
      }
    } catch (err) {
      if (!ref.mounted) return;
      state = state.copyWith(isMarkingAllRead: false);
      unReadNotificationCount.value = currentUnreadCount;
      state = state.copyWith(
        model: state.model.copyWith(
          unreadCount: currentUnreadCount,
          notifications: previousList,
        ),
      );
      if (kDebugMode) print("Error marking all notifications read: $err");
      CustomSnackBar.showCustomToast(
        title: "Something Went Wrong!",
        message: err.toString(),
      );
    }
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
