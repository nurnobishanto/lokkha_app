import 'package:lokkha/features/question_bank/data/models/random_question_model.dart';
import 'package:lokkha/features/question_bank/domain/repositories/question_bank_repository.dart';

class GetRandomQuestionUseCase {
  final QuestionBankRepository repository;

  GetRandomQuestionUseCase(this.repository);

  Future<RandomQuestionModel?> call() {
    return repository.getRandomQuestion();
  }
}
