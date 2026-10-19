import '../../domain/repositories/exam_repository.dart';
import '../datasources/exam_remote_data_source.dart';
import '../models/user_exam_v1_model.dart';
import '../models/exam_lifecycle_models.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource remoteDataSource;

  ExamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserExamsV1Response> getUserExams({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  }) {
    return remoteDataSource.getUserExams(
      page: page,
      perPage: perPage,
      filter: filter,
      search: search,
    );
  }

  @override
  Future<ExamInstructionsResponse> getExamInstructions(int examId) {
    return remoteDataSource.getExamInstructions(examId);
  }

  @override
  Future<ExamStartResponse> startExam(int examId) {
    return remoteDataSource.startExam(examId);
  }

  @override
  Future<ActiveExamSessionResponse> getActiveSession(int examId) {
    return remoteDataSource.getActiveSession(examId);
  }

  @override
  Future<SaveAnswerResponse> saveAnswer({
    required int examId,
    required int questionId,
    required dynamic answer,
  }) {
    return remoteDataSource.saveAnswer(
      examId: examId,
      questionId: questionId,
      answer: answer,
    );
  }

  @override
  Future<ExamSubmitResponse> submitExam({
    required int examId,
    required Map<String, dynamic> answers,
    required int totalDuration,
  }) {
    return remoteDataSource.submitExam(
      examId: examId,
      answers: answers,
      totalDuration: totalDuration,
    );
  }

  @override
  Future<ExamLeaderboardResponse> getExamLeaderboard(int examId) {
    return remoteDataSource.getExamLeaderboard(examId);
  }
}
