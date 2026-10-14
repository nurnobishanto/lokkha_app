import 'package:lokkha/features/home/data/models/home_feed_model.dart';

abstract class HomeRepository {
  Future<HomeFeedModel> getHomeFeed({
    String sections = 'all',
    String sliderType = 'app',
  });

  Future<HomeContestHubModel?> getContests() async => null;
  Future<HomeQuestionBanksModel?> getQuestionBanks() async => null;
  Future<HomeCareerUpdatesModel?> getJobsExams() async => null;
  Future<HomeStatsModel?> getStats() async => null;
  Future<HomeVocabularyModel?> getVocabulary() async => null;
  Future<List<HomeHallOfFameItem>> getTestimonials() async => const [];
}
