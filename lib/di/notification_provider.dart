import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:lokkha/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:lokkha/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lokkha/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:lokkha/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:lokkha/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

/// Notification Remote Data Source Provider
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  final client = ref.watch(restClientProvider);
  return NotificationRemoteDataSourceImpl(client: client);
});

/// Notification Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Get Notifications Use Case Provider
final getNotificationsUseCaseProvider =
    Provider<GetNotificationsUseCase>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetNotificationsUseCase(repository);
});

/// Mark Notification Read Use Case Provider
final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return MarkNotificationReadUseCase(repository);
});

/// Mark All Notifications Read Use Case Provider
final markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return MarkAllNotificationsReadUseCase(repository);
});
