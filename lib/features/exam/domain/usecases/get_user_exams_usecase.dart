import '../../data/models/user_exam_v1_model.dart';
import '../repositories/exam_repository.dart';

class GetUserExamsUseCase {
  final ExamRepository repository;

  GetUserExamsUseCase({ExamRepository? repository})
      : repository = repository ?? ExamRepository();

  Future<UserExamsV1Response> call({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  }) {
    return repository.getUserExams(
      page: page,
      perPage: perPage,
      filter: filter,
      search: search,
    );
  }
}
