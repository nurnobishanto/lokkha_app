import 'package:flutter/foundation.dart';
import '../../../../../utils/constants.dart';
import '../../../../data/network/api_client.dart';

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
      totalInvited: json['total_invited'] as int? ?? 0,
      earnedPoints: json['earned_points'] as int? ?? 0,
      successfulReferrals: json['successful_referrals'] as int? ?? 0,
      referredUsers: (json['referred_users'] as List<dynamic>?) ?? [],
    );
  }
}

class ReferralRepository {
  /// Fetch Referral statistics and rewards from V1 API
  Future<ReferralStats?> getReferralStats() async {
    try {
      final response = await ApiClient.get(AppConstants.v1Referrals);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data'] as Map<String, dynamic>
            : response.data as Map<String, dynamic>;
        return ReferralStats.fromJson(data);
      }
    } catch (e) {
      debugPrint('[ReferralRepository] Error fetching referral stats: $e');
    }
    return null;
  }
}
