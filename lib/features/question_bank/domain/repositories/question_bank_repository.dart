import 'package:lokkha/features/question_bank/data/models/random_question_model.dart';

abstract class QuestionBankRepository {
  Future<RandomQuestionModel?> getRandomQuestion();
}
