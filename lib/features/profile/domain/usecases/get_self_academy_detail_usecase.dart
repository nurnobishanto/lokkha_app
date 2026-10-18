import '../../data/models/self_exam_model.dart';
import '../../data/models/self_exam_detail_model.dart';
import '../repositories/profile_repository.dart';

class GetSelfAcademyDetailUseCase {
  final ProfileRepository repository;

  GetSelfAcademyDetailUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<SelfExamDetailModel> call(
    dynamic id, {
    SelfExamModel? summaryExam,
  }) {
    return repository.getSelfAcademyDetail(id, summaryExam: summaryExam);
  }
}
