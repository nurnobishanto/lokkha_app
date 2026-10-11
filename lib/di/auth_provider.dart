import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lokkha/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lokkha/features/auth/domain/repositories/auth_repository.dart';
import 'package:lokkha/features/auth/domain/usecases/check_phone_usecase.dart';
import 'package:lokkha/features/auth/domain/usecases/login_usecase.dart';
import 'package:lokkha/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lokkha/features/auth/domain/usecases/register_usecase.dart';
import 'package:lokkha/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:lokkha/features/auth/domain/usecases/verify_otp_usecase.dart';

/// Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

/// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Use Cases Providers
final checkPhoneUseCaseProvider = Provider<CheckPhoneUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckPhoneUseCase(repository);
});

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SendOtpUseCase(repository);
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyOtpUseCase(repository);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});
