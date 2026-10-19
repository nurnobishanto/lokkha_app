import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:lokkha/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lokkha/features/profile/domain/repositories/profile_repository.dart';
import 'package:lokkha/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_devices_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/terminate_device_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/logout_other_devices_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_dashboard_overview_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_exam_history_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_exam_history_detail_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_user_orders_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_order_details_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_self_academy_history_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_self_academy_detail_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_content_history_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/toggle_save_question_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_accuracy_analytics_usecase.dart';

/// Profile Remote Data Source Provider
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final client = ref.watch(restClientProvider);
  return ProfileRemoteDataSourceImpl(client: client);
});

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Profile Use Case Providers
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getDevicesUseCaseProvider = Provider<GetDevicesUseCase>((ref) {
  return GetDevicesUseCase(repository: ref.watch(profileRepositoryProvider));
});

final terminateDeviceUseCaseProvider = Provider<TerminateDeviceUseCase>((ref) {
  return TerminateDeviceUseCase(repository: ref.watch(profileRepositoryProvider));
});

final logoutOtherDevicesUseCaseProvider = Provider<LogoutOtherDevicesUseCase>((ref) {
  return LogoutOtherDevicesUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getDashboardOverviewUseCaseProvider = Provider<GetDashboardOverviewUseCase>((ref) {
  return GetDashboardOverviewUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getExamHistoryUseCaseProvider = Provider<GetExamHistoryUseCase>((ref) {
  return GetExamHistoryUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getExamHistoryDetailUseCaseProvider = Provider<GetExamHistoryDetailUseCase>((ref) {
  return GetExamHistoryDetailUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getUserOrdersUseCaseProvider = Provider<GetUserOrdersUseCase>((ref) {
  return GetUserOrdersUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getOrderDetailsUseCaseProvider = Provider<GetOrderDetailsUseCase>((ref) {
  return GetOrderDetailsUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getSelfAcademyHistoryUseCaseProvider = Provider<GetSelfAcademyHistoryUseCase>((ref) {
  return GetSelfAcademyHistoryUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getSelfAcademyDetailUseCaseProvider = Provider<GetSelfAcademyDetailUseCase>((ref) {
  return GetSelfAcademyDetailUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getContentHistoryUseCaseProvider = Provider<GetContentHistoryUseCase>((ref) {
  return GetContentHistoryUseCase(repository: ref.watch(profileRepositoryProvider));
});

final toggleSaveQuestionUseCaseProvider = Provider<ToggleSaveQuestionUseCase>((ref) {
  return ToggleSaveQuestionUseCase(repository: ref.watch(profileRepositoryProvider));
});

final getAccuracyAnalyticsUseCaseProvider = Provider<GetAccuracyAnalyticsUseCase>((ref) {
  return GetAccuracyAnalyticsUseCase(repository: ref.watch(profileRepositoryProvider));
});
