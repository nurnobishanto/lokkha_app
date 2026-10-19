import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/rest_client.dart';
import '../models/user_exam_v1_model.dart';
import '../models/exam_lifecycle_models.dart';

abstract class ExamRemoteDataSource {
  Future<UserExamsV1Response> getUserExams({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  });

  Future<ExamInstructionsResponse> getExamInstructions(int examId);

  Future<ExamStartResponse> startExam(int examId);

  Future<ActiveExamSessionResponse> getActiveSession(int examId);

  Future<SaveAnswerResponse> saveAnswer({
    required int examId,
    required int questionId,
    required dynamic answer,
  });

  Future<ExamSubmitResponse> submitExam({
    required int examId,
    required Map<String, dynamic> answers,
    required int totalDuration,
  });

  Future<ExamLeaderboardResponse> getExamLeaderboard(int examId);
}

class ExamRemoteDataSourceImpl implements ExamRemoteDataSource {
  final RestClient _client;

  ExamRemoteDataSourceImpl({RestClient? client}) : _client = client ?? RestClient();

  @override
  Future<UserExamsV1Response> getUserExams({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };

      if (filter != null && filter.isNotEmpty && filter != 'all') {
        queryParams['type'] = filter;
        queryParams['filter'] = filter;
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _client.get(
        Endpoints.v1UserExams,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return UserExamsV1Response.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid user exams response format from ${Endpoints.v1UserExams}');
    } catch (e) {
      debugPrint('[ExamRemoteDataSource] getUserExams error: $e');
      rethrow;
    }
  }

  @override
  Future<ExamInstructionsResponse> getExamInstructions(int examId) async {
    try {
      final response = await _client.get(Endpoints.v1ExamInstructions(examId));
      if (response.data is Map<String, dynamic>) {
        return ExamInstructionsResponse.fromJson(
            response.data as Map<String, dynamic>);
      }
      return const ExamInstructionsResponse();
    } catch (e) {
      debugPrint('[ExamRemoteDataSource] getExamInstructions error: $e');
      rethrow;
    }
  }

  @override
  Future<ExamStartResponse> startExam(int examId) async {
    try {
      final response = await _client.post(Endpoints.v1ExamStart(examId));
      if (response.data is Map<String, dynamic>) {
        return ExamStartResponse.fromJson(response.data as Map<String, dynamic>);
      }
      return const ExamStartResponse();
    } catch (e) {
      debugPrint('[ExamRemoteDataSource] startExam error: $e');
      rethrow;
    }
  }

  @override
  Future<ActiveExamSessionResponse> getActiveSession(int examId) async {
    try {
      final response = await _client.get(Endpoints.v1ExamSession(examId));
      if (response.data is Map<String, dynamic>) {
        return ActiveExamSessionResponse.fromJson(
            response.data as Map<String, dynamic>);
      }
      return const ActiveExamSessionResponse();
    } catch (e) {
      debugPrint('[ExamRemoteDataSource] getActiveSession error: $e');
      rethrow;
    }
  }

  @override
  Future<SaveAnswerResponse> saveAnswer({
    required int examId,
    required int questionId,
    required dynamic answer,
  }) async {
    try {
      final response = await _client.post(
        Endpoints.v1ExamSaveAnswer(examId),
        data: {
          'question_id': questionId,
          'answer': answer,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return SaveAnswerResponse.fromJson(
            response.data as Map<String, dynamic>);
      }
      return const SaveAnswerResponse();
    } catch (e) {
      debugPrint('[ExamRemoteDataSource] saveAnswer error: $e');
      rethrow;
    }
  }

  @override
  Future<ExamSubmitResponse> submitExam({
    required int examId,
    required Map<String, dynamic> answers,
    required int totalDuration,
  }) async {
    try {
      final response = await _client.post(
        Endpoints.v1ExamSubmit(examId),
        data: {
          'answers': answers,
          'total_duration': totalDuration,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return ExamSubmitResponse.fromJson(
            response.data as Map<String, dynamic>);
      }
      return const ExamSubmitResponse();
    } catch (e) {
      debugPrint('[ExamRemoteDataSource] submitExam error: $e');
      rethrow;
    }
  }

  @override
  Future<ExamLeaderboardResponse> getExamLeaderboard(int examId) async {
    try {
      final response = await _client.get(Endpoints.v1ExamLeaderboard(examId));
      if (response.data is Map<String, dynamic>) {
        return ExamLeaderboardResponse.fromJson(
            response.data as Map<String, dynamic>);
      }
      return const ExamLeaderboardResponse();
    } catch (e) {
      debugPrint('[ExamRemoteDataSource] getExamLeaderboard error: $e');
      rethrow;
    }
  }
}
