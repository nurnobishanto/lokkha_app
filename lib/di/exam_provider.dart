import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/exam/data/datasources/exam_remote_data_source.dart';
import 'package:lokkha/features/exam/data/repositories/exam_repository_impl.dart';
import 'package:lokkha/features/exam/domain/repositories/exam_repository.dart';
import 'package:lokkha/features/exam/domain/usecases/get_user_exams_usecase.dart';

/// Exam Remote Data Source Provider
final examRemoteDataSourceProvider = Provider<ExamRemoteDataSource>((ref) {
  final client = ref.watch(restClientProvider);
  return ExamRemoteDataSourceImpl(client: client);
});

/// Exam Repository Provider
final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final remoteDataSource = ref.watch(examRemoteDataSourceProvider);
  return ExamRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Get User Exams Use Case Provider
final getUserExamsUseCaseProvider = Provider<GetUserExamsUseCase>((ref) {
  final repository = ref.watch(examRepositoryProvider);
  return GetUserExamsUseCase(repository: repository);
});
