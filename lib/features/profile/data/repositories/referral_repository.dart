import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/features/profile/data/models/referral_model.dart';

export 'package:lokkha/features/profile/data/models/referral_model.dart';

/// Legacy model retained for backward compatibility
class ReferralStats {
  final String referralCode;
  final String referralLink;
  final int totalInvited;
  final int earnedPoints;
  final int successfulReferrals;
  final List<dynamic> referredUsers;

  ReferralStats({
    required this.referralCode,
    required this.referralLink,
    required this.totalInvited,
    required this.earnedPoints,
    required this.successfulReferrals,
    required this.referredUsers,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      referralCode: json['referral_code'] as String? ?? '',
      referralLink: json['referral_link'] as String? ?? '',
      totalInvited: json['total_referrals'] as int? ??
          json['total_invited'] as int? ??
          0,
      earnedPoints: json['total_points_earned'] as int? ??
          json['earned_points'] as int? ??
          0,
      successfulReferrals: json['successful_referrals'] as int? ?? 0,
      referredUsers: (json['items'] as List<dynamic>?) ??
          (json['referred_users'] as List<dynamic>?) ??
          [],
    );
  }
}

class ReferralRepository {
  final RestClient _client;

  ReferralRepository({RestClient? client}) : _client = client ?? RestClient();

  /// Fetch full Referral data from V1 API (/api/v1/user/referrals)
  Future<ReferralResponse?> getReferralDetails({int page = 1, int perPage = 15}) async {
    try {
      final response = await _client.get(
        Endpoints.v1Referrals,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return ReferralResponse.fromJson(response.data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[ReferralRepository] Error fetching referral details: $e');
    }
    return null;
  }

  /// Legacy helper retained for backward compatibility
  Future<ReferralStats?> getReferralStats() async {
    try {
      final res = await getReferralDetails();
      if (res != null && res.success) {
        return ReferralStats(
          referralCode: res.data.referralCode,
          referralLink: res.data.referralLink,
          totalInvited: res.data.totalReferrals,
          earnedPoints: res.data.totalPointsEarned,
          successfulReferrals: res.data.successfulReferrals,
          referredUsers: res.data.items.map((e) => e.toJson()).toList(),
        );
      }
    } catch (e) {
      debugPrint('[ReferralRepository] Error fetching referral stats: $e');
    }
    return null;
  }
}
