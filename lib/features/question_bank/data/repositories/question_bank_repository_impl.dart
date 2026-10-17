import 'package:lokkha/features/question_bank/data/datasources/question_bank_remote_data_source.dart';
import 'package:lokkha/features/question_bank/data/models/random_question_model.dart';
import 'package:lokkha/features/question_bank/domain/repositories/question_bank_repository.dart';

class QuestionBankRepositoryImpl implements QuestionBankRepository {
  final QuestionBankRemoteDataSource remoteDataSource;

  QuestionBankRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RandomQuestionModel?> getRandomQuestion() {
    return remoteDataSource.getRandomQuestion();
  }
}
