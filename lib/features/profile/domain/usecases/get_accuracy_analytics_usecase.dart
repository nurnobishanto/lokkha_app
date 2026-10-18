import '../repositories/profile_repository.dart';
import '../../data/models/accuracy_response_model.dart';

class GetAccuracyAnalyticsUseCase {
  final ProfileRepository repository;

  GetAccuracyAnalyticsUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<AccuracyResponseModel> call({int page = 1}) {
    return repository.getAccuracyAnalytics(page: page);
  }
}
