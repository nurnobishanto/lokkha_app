import '../../data/datasources/exam_remote_data_source.dart';
import '../../data/models/user_exam_v1_model.dart';
import '../../data/models/exam_lifecycle_models.dart';
import '../../data/repositories/exam_repository_impl.dart';

abstract class ExamRepository {
  factory ExamRepository() =>
      ExamRepositoryImpl(remoteDataSource: ExamRemoteDataSourceImpl());

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
