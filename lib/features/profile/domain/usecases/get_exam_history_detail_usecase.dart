import '../../data/models/exam_history_model.dart';
import '../../data/models/exam_review_detail_model.dart';
import '../repositories/profile_repository.dart';

class GetExamHistoryDetailUseCase {
  final ProfileRepository repository;

  GetExamHistoryDetailUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<ExamReviewDetailModel> call(
    dynamic id, {
    ExamHistoryModel? summaryExam,
  }) {
    return repository.getExamHistoryDetail(id, summaryExam: summaryExam);
  }
}
