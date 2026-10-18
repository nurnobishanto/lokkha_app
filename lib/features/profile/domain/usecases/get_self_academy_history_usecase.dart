import '../../data/models/self_exam_model.dart';
import '../repositories/profile_repository.dart';

class GetSelfAcademyHistoryUseCase {
  final ProfileRepository repository;

  GetSelfAcademyHistoryUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<SelfAcademyHistoryResponseModel> call({int page = 1}) {
    return repository.getSelfAcademyHistory(page: page);
  }
}
