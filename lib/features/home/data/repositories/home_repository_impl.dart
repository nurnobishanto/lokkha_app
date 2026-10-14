import 'package:lokkha/features/home/data/datasources/home_remote_data_source.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl({HomeRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? HomeRemoteDataSourceImpl();

  @override
  Future<HomeFeedModel> getHomeFeed({
    String sections = 'all',
    String sliderType = 'app',
  }) {
    return _remoteDataSource.getHomeFeed(
      sections: sections,
      sliderType: sliderType,
    );
  }

  @override
  Future<HomeContestHubModel?> getContests() => _remoteDataSource.getContests();

  @override
  Future<HomeQuestionBanksModel?> getQuestionBanks() =>
      _remoteDataSource.getQuestionBanks();

  @override
  Future<HomeCareerUpdatesModel?> getJobsExams() =>
      _remoteDataSource.getJobsExams();

  @override
  Future<HomeStatsModel?> getStats() => _remoteDataSource.getStats();

  @override
  Future<HomeVocabularyModel?> getVocabulary() =>
      _remoteDataSource.getVocabulary();

  @override
  Future<List<HomeHallOfFameItem>> getTestimonials() =>
      _remoteDataSource.getTestimonials();
}
