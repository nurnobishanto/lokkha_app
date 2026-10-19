import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/features/profile/data/models/reward_points_model.dart';

export 'package:lokkha/features/profile/data/models/reward_points_model.dart';

class RewardPointsRepository {
  final RestClient _client;

  RewardPointsRepository({RestClient? client}) : _client = client ?? RestClient();

  /// Fetch live reward points balance and metrics (/api/v1/user/reward-points)
  Future<RewardPointsBalance?> getRewardPoints() async {
    try {
      final response = await _client.get(Endpoints.v1RewardPoints);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final res = RewardPointsResponse.fromJson(response.data as Map<String, dynamic>);
          return res.data;
        }
      }
    } catch (e) {
      debugPrint('[RewardPointsRepository] Error fetching reward points: $e');
    }
    return null;
  }

  /// Fetch paginated reward points transaction ledger (/api/v1/user/reward-points/transactions)
  /// [tab] filters by: 'all', 'earned', or 'used'
  Future<RewardTransactionsResponse> getRewardTransactions({
    String tab = 'all',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'tab': tab,
        'page': page,
        'per_page': perPage,
      };

      final response = await _client.get(
        Endpoints.v1RewardTransactions,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return RewardTransactionsResponse.fromJson(
            response.data as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      debugPrint('[RewardPointsRepository] Error fetching reward transactions: $e');
    }
    return const RewardTransactionsResponse();
  }
}
