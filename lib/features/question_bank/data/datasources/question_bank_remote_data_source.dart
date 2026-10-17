import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/features/question_bank/data/models/random_question_model.dart';

abstract class QuestionBankRemoteDataSource {
  Future<RandomQuestionModel?> getRandomQuestion();
}

class QuestionBankRemoteDataSourceImpl implements QuestionBankRemoteDataSource {
  final RestClient _client;

  QuestionBankRemoteDataSourceImpl({RestClient? client})
      : _client = client ?? RestClient();

  @override
  Future<RandomQuestionModel?> getRandomQuestion() async {
    try {
      final response = await _client.get(Endpoints.questionBankRandom);
      if (response.data is Map) {
        final parsed = RandomQuestionResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (parsed.success && parsed.data != null) {
          return parsed.data;
        }
      }
    } catch (e) {
      debugPrint('[QuestionBankRemoteDataSource.getRandomQuestion] Error: $e');
    }
    return null;
  }
}
