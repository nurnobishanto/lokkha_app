import 'package:flutter/foundation.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/data/models/current_affairs_v1_models.dart';

abstract class CurrentAffairsRepository {
  Future<CurrentAffairsFeedResponse> getFeed({
    String? type,
    String? search,
    String? date,
    String? fromDate,
    String? toDate,
    String? month,
    int? year,
    int? subjectId,
    String? sortBy,
    int perPage = 20,
    int page = 1,
  });

  Future<CurrentAffairsMonthlyDigestResponse> getMonthlyDigest({
    String? month,
    String? format,
    int? subjectId,
  });

  Future<List<CurrentAffairsMonthItem>> getMonths();

  Future<CurrentAffairsCategoriesResponse> getCategories();

  Future<CurrentAffairsLatestResponse> getLatest();

  Future<CurrentAffairsDetailResponse> getQuestionDetail(dynamic id);

  Future<CurrentAffairsBookmarkResponse> toggleBookmark(dynamic id);
}

class CurrentAffairsRepositoryImpl implements CurrentAffairsRepository {
  final RestClient _client;

  CurrentAffairsRepositoryImpl({RestClient? client})
      : _client = client ?? RestClient();

  Map<String, String> _buildHeaders() {
    final token = MySharedPref.getUserToken();
    return {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<CurrentAffairsFeedResponse> getFeed({
    String? type,
    String? search,
    String? date,
    String? fromDate,
    String? toDate,
    String? month,
    int? year,
    int? subjectId,
    String? sortBy,
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> query = {
        'page': page,
        'per_page': perPage,
      };

      if (type != null && type.isNotEmpty && type != 'all') {
        query['type'] = type;
      }
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (date != null && date.trim().isNotEmpty) {
        query['date'] = date.trim();
      }
      if (fromDate != null && fromDate.trim().isNotEmpty) {
        query['from_date'] = fromDate.trim();
      }
      if (toDate != null && toDate.trim().isNotEmpty) {
        query['to_date'] = toDate.trim();
      }
      if (month != null && month.trim().isNotEmpty) {
        query['month'] = month.trim();
      }
      if (year != null && year > 0) {
        query['year'] = year;
      }
      if (subjectId != null && subjectId > 0) {
        query['subject_id'] = subjectId;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        query['sort_by'] = sortBy;
      }

      final response = await _client.get(
        Endpoints.currentAffairs,
        queryParameters: query,
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final map = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return CurrentAffairsFeedResponse.fromJson(map);
      }
    } catch (e) {
      debugPrint('[CurrentAffairsRepository] getFeed error: $e');
    }
    return const CurrentAffairsFeedResponse(success: false);
  }

  @override
  Future<CurrentAffairsMonthlyDigestResponse> getMonthlyDigest({
    String? month,
    String? format,
    int? subjectId,
  }) async {
    try {
      final Map<String, dynamic> query = {};
      if (month != null && month.isNotEmpty) {
        query['month'] = month;
      }
      if (format != null && format.isNotEmpty) {
        query['format'] = format;
      }
      if (subjectId != null && subjectId > 0) {
        query['subject_id'] = subjectId;
      }

      final response = await _client.get(
        Endpoints.currentAffairsMonthlyDigest,
        queryParameters: query.isNotEmpty ? query : null,
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final map = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return CurrentAffairsMonthlyDigestResponse.fromJson(map);
      }
    } catch (e) {
      debugPrint('[CurrentAffairsRepository] getMonthlyDigest error: $e');
    }
    return CurrentAffairsMonthlyDigestResponse(
      success: false,
      month: month ?? '',
      monthName: '',
    );
  }

  @override
  Future<List<CurrentAffairsMonthItem>> getMonths() async {
    try {
      final response = await _client.get(
        Endpoints.currentAffairsMonths,
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        List<dynamic> list = [];
        if (rawData is Map) {
          if (rawData['data'] is Map && (rawData['data'] as Map)['items'] is List) {
            list = (rawData['data'] as Map)['items'] as List;
          } else if (rawData['data'] is List) {
            list = rawData['data'] as List;
          } else if (rawData['items'] is List) {
            list = rawData['items'] as List;
          }
        } else if (rawData is List) {
          list = rawData;
        }

        return list
            .map((item) => CurrentAffairsMonthItem.fromJson(
                item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('[CurrentAffairsRepository] getMonths error: $e');
    }
    return [];
  }

  @override
  Future<CurrentAffairsCategoriesResponse> getCategories() async {
    try {
      final response = await _client.get(
        Endpoints.currentAffairsCategories,
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final map = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return CurrentAffairsCategoriesResponse.fromJson(map);
      }
    } catch (e) {
      debugPrint('[CurrentAffairsRepository] getCategories error: $e');
    }
    return const CurrentAffairsCategoriesResponse(success: false);
  }

  @override
  Future<CurrentAffairsLatestResponse> getLatest() async {
    try {
      final response = await _client.get(
        Endpoints.currentAffairsLatest,
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final map = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return CurrentAffairsLatestResponse.fromJson(map);
      }
    } catch (e) {
      debugPrint('[CurrentAffairsRepository] getLatest error: $e');
    }
    return const CurrentAffairsLatestResponse(success: false);
  }

  @override
  Future<CurrentAffairsDetailResponse> getQuestionDetail(dynamic id) async {
    try {
      final response = await _client.get(
        Endpoints.currentAffairsDetails(id),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final map = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return CurrentAffairsDetailResponse.fromJson(map);
      }
    } catch (e) {
      debugPrint('[CurrentAffairsRepository] getQuestionDetail error: $e');
    }
    return const CurrentAffairsDetailResponse(success: false);
  }

  @override
  Future<CurrentAffairsBookmarkResponse> toggleBookmark(dynamic id) async {
    try {
      final response = await _client.post(
        Endpoints.currentAffairsToggleBookmark(id),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final map = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return CurrentAffairsBookmarkResponse.fromJson(map);
      }
    } catch (e) {
      debugPrint('[CurrentAffairsRepository] toggleBookmark error: $e');
    }
    return const CurrentAffairsBookmarkResponse(
      success: false,
      isBookmarked: false,
    );
  }
}
