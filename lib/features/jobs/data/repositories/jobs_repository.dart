import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/jobs/data/models/job_list_model.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepositoryImpl();
});

abstract class JobsRepository {
  Future<JobListModel> getJobs({
    int page = 1,
    int perPage = 20,
    int? departmentId,
    String? search,
  });

  Future<Job?> getJobDetail(dynamic id);

  Future<List<JobDepartment>> getDepartments();
}

class JobsRepositoryImpl implements JobsRepository {
  final RestClient _client;

  JobsRepositoryImpl({RestClient? client}) : _client = client ?? RestClient();

  Map<String, String> _buildHeaders() {
    final token = MySharedPref.getUserToken();
    return {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<JobListModel> getJobs({
    int page = 1,
    int perPage = 20,
    int? departmentId,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (departmentId != null && departmentId > 0) {
      queryParams['department_id'] = departmentId;
    }

    try {
      final response = await _client.get(
        Endpoints.v1Jobs,
        queryParameters: queryParams,
        headers: _buildHeaders(),
      );

      final rawData = response.data;
      if (rawData is Map) {
        final dataMap = rawData is Map<String, dynamic>
            ? rawData
            : Map<String, dynamic>.from(rawData);
        return JobListModel.fromJson(dataMap);
      }
    } catch (e) {
      debugPrint('[JobsRepository.getJobs] Error: $e');
    }

    return JobListModel(
      status: false,
      success: false,
      message: 'Failed to retrieve jobs.',
      jobs: Jobs(
        currentPage: page,
        lastPage: 1,
        total: 0,
        data: [],
      ),
    );
  }

  @override
  Future<Job?> getJobDetail(dynamic id) async {
    try {
      final response = await _client.get(
        Endpoints.v1JobDetail(id),
        headers: _buildHeaders(),
      );

      if (response.data is Map) {
        final data = response.data['data'] ?? response.data['job'];
        if (data is Map) {
          final dataMap = data is Map<String, dynamic>
              ? data
              : Map<String, dynamic>.from(data);
          return Job.fromJson(dataMap);
        }
      }
    } catch (e) {
      debugPrint('[JobsRepository.getJobDetail] Error: $e');
    }
    return null;
  }

  @override
  Future<List<JobDepartment>> getDepartments() async {
    try {
      final response = await _client.get(
        Endpoints.v1JobDepartments,
        headers: _buildHeaders(),
      );

      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List)
            .whereType<Map>()
            .map((item) => JobDepartment.fromJson(
                  item is Map<String, dynamic>
                      ? item
                      : Map<String, dynamic>.from(item),
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('[JobsRepository.getDepartments] Error: $e');
    }
    return [];
  }
}
