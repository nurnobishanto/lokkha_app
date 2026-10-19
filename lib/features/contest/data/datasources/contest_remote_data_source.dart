import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/contest/data/models/all_contest_model.dart';
import 'package:lokkha/features/contest/data/models/contest_result_model.dart';
import 'package:lokkha/features/contest/data/models/contest_start_model.dart';
import 'package:lokkha/features/contest/data/models/contest_submit_model.dart';
import 'package:lokkha/features/contest/data/models/latest_contest_model.dart';

abstract class ContestRemoteDataSource {
  Future<LatestContestModel?> getLatestContest();

  Future<AllContestModel?> getAllContests();

  Future<ContestResultModel?> getLatestContestResult();

  Future<ContestStartModel?> startContest(int contestId);

  Future<ContestSubmitModel?> submitContest({
    required int contestId,
    required List<Map<String, dynamic>> userAnswers,
  });
}

class ContestRemoteDataSourceImpl implements ContestRemoteDataSource {
  final RestClient _client;

  ContestRemoteDataSourceImpl({RestClient? client})
      : _client = client ?? RestClient();

  Map<String, String> _buildHeaders() {
    String token = '';
    try {
      token = MySharedPref.getUserToken();
    } catch (_) {}

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<LatestContestModel?> getLatestContest() async {
    try {
      final response = await _client.get(
        Endpoints.latestContest,
        headers: _buildHeaders(),
      );
      if (response.data is Map && response.data['status'] == true) {
        return LatestContestModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('[ContestRemoteDataSource.getLatestContest] Error: $e');
    }
    return null;
  }

  @override
  Future<AllContestModel?> getAllContests() async {
    try {
      final response = await _client.get(
        Endpoints.allContestList,
        headers: _buildHeaders(),
      );
      if (response.data is Map && response.data['status'] == true) {
        return AllContestModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('[ContestRemoteDataSource.getAllContests] Error: $e');
    }
    return null;
  }

  @override
  Future<ContestResultModel?> getLatestContestResult() async {
    try {
      final response = await _client.get(
        Endpoints.latestContestResult,
        headers: _buildHeaders(),
      );
      if (response.data is Map && response.data['status'] == true) {
        return ContestResultModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('[ContestRemoteDataSource.getLatestContestResult] Error: $e');
    }
    return null;
  }

  @override
  Future<ContestStartModel?> startContest(int contestId) async {
    try {
      final response = await _client.post(
        '${Endpoints.startContest}$contestId/start',
        headers: _buildHeaders(),
      );
      if (response.data is Map) {
        return ContestStartModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('[ContestRemoteDataSource.startContest] Error: $e');
    }
    return null;
  }

  @override
  Future<ContestSubmitModel?> submitContest({
    required int contestId,
    required List<Map<String, dynamic>> userAnswers,
  }) async {
    try {
      final response = await _client.post(
        '${Endpoints.startContest}$contestId/submit',
        headers: _buildHeaders(),
        data: {
          'user_answers': userAnswers,
        },
      );
      if (response.data is Map) {
        return ContestSubmitModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('[ContestRemoteDataSource.submitContest] Error: $e');
    }
    return null;
  }
}
