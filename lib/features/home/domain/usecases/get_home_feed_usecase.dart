import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/domain/repositories/home_repository.dart';

class GetHomeFeedUseCase {
  final HomeRepository _repository;

  GetHomeFeedUseCase(this._repository);

  Future<HomeFeedModel> call({
    String sections = 'all',
    String sliderType = 'app',
  }) {
    return _repository.getHomeFeed(
      sections: sections,
      sliderType: sliderType,
    );
  }
}
