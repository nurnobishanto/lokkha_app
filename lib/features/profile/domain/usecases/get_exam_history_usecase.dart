import '../../data/models/exam_history_model.dart';
import '../repositories/profile_repository.dart';

class GetExamHistoryUseCase {
  final ProfileRepository repository;

  GetExamHistoryUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<ExamHistoryResponseModel> call({int page = 1}) {
    return repository.getExamHistory(page: page);
  }
}
