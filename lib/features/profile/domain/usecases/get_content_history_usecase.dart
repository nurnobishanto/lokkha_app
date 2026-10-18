import '../../data/models/content_history_model.dart';
import '../repositories/profile_repository.dart';

class GetContentHistoryUseCase {
  final ProfileRepository repository;

  GetContentHistoryUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<ContentHistoryResponseModel> call() {
    return repository.getContentHistory();
  }
}
