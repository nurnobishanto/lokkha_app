import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/question_bank/data/datasources/question_bank_remote_data_source.dart';
import 'package:lokkha/features/question_bank/data/repositories/question_bank_repository_impl.dart';
import 'package:lokkha/features/question_bank/domain/repositories/question_bank_repository.dart';
import 'package:lokkha/features/question_bank/domain/usecases/get_random_question_usecase.dart';

/// Data Source Provider
final questionBankRemoteDataSourceProvider =
    Provider<QuestionBankRemoteDataSource>((ref) {
  final client = ref.watch(restClientProvider);
  return QuestionBankRemoteDataSourceImpl(client: client);
});

/// Repository Provider
final questionBankRepositoryProvider = Provider<QuestionBankRepository>((ref) {
  final remoteDataSource = ref.watch(questionBankRemoteDataSourceProvider);
  return QuestionBankRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Use Case Provider
final getRandomQuestionUseCaseProvider =
    Provider<GetRandomQuestionUseCase>((ref) {
  final repository = ref.watch(questionBankRepositoryProvider);
  return GetRandomQuestionUseCase(repository);
});
