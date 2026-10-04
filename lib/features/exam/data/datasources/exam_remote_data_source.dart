import 'package:flutter/foundation.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/network/api_client.dart';
import '../models/user_exam_v1_model.dart';

abstract class ExamRemoteDataSource {
  Future<UserExamsV1Response> getUserExams({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  });
}

class ExamRemoteDataSourceImpl implements ExamRemoteDataSource {
  @override
  Future<UserExamsV1Response> getUserExams({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };

      if (filter != null && filter.isNotEmpty && filter != 'all') {
        queryParams['type'] = filter;
        queryParams['filter'] = filter;
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await ApiClient.get(
        AppConstants.v1UserExams,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return UserExamsV1Response.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid user exams response format from ${AppConstants.v1UserExams}');
    } catch (e) {
      debugPrint('[ExamRemoteDataSource] getUserExams error: $e');
      rethrow;
    }
  }
}
