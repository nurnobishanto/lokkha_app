import 'package:dio/dio.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeFeedModel> getHomeFeed({
    String sections = 'all',
    String sliderType = 'app',
  });

  Future<HomeContestHubModel?> getContests();
  Future<HomeQuestionBanksModel?> getQuestionBanks();
  Future<HomeCareerUpdatesModel?> getJobsExams();
  Future<HomeStatsModel?> getStats();
  Future<HomeVocabularyModel?> getVocabulary();
  Future<List<HomeHallOfFameItem>> getTestimonials();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final RestClient _client;

  HomeRemoteDataSourceImpl({RestClient? client})
      : _client = client ?? RestClient();

  @override
  Future<HomeFeedModel> getHomeFeed({
    String sections = 'all',
    String sliderType = 'app',
  }) async {
    try {
      final response = await _client.get(
        Endpoints.homeFeed,
        queryParameters: {
          'sections': sections,
          'slider_type': sliderType,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return HomeFeedModel.fromJson(response.data as Map<String, dynamic>);
      }
      return HomeFeedModel(
        success: false,
        message: 'Invalid server response format.',
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message']?.toString() ?? e.message)
          : e.message;
      return HomeFeedModel(
        success: false,
        message: msg ?? 'Failed to load home feed.',
      );
    } catch (e) {
      return HomeFeedModel(
        success: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<HomeContestHubModel?> getContests() async {
    try {
      final response = await _client.get(Endpoints.homeContests);
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return HomeContestHubModel.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HomeQuestionBanksModel?> getQuestionBanks() async {
    try {
      final response = await _client.get(Endpoints.homeQuestionBanks);
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return HomeQuestionBanksModel.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HomeCareerUpdatesModel?> getJobsExams() async {
    try {
      final response = await _client.get(Endpoints.homeJobsExams);
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return HomeCareerUpdatesModel.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HomeStatsModel?> getStats() async {
    try {
      final response = await _client.get(Endpoints.homeStats);
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return HomeStatsModel.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HomeVocabularyModel?> getVocabulary() async {
    try {
      final response = await _client.get(Endpoints.homeVocabulary);
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return HomeVocabularyModel.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<HomeHallOfFameItem>> getTestimonials() async {
    try {
      final response = await _client.get(Endpoints.homeTestimonials);
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data['items'] ?? response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((e) => HomeHallOfFameItem.fromJson(e))
              .toList();
        }
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
