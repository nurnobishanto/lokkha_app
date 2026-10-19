import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

/// Privacy-masked referred student user
class ReferredUser {
  final String name;
  final String phoneMasked;

  const ReferredUser({
    required this.name,
    required this.phoneMasked,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      name: json['name'] as String? ?? 'ব্যবহারকারী',
      phoneMasked: json['phone_masked'] as String? ??
          json['phone'] as String? ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone_masked': phoneMasked,
      };
}

/// Referral history item
class ReferralItem {
  final int id;
  final String referralCode;
  final int rewardPoints;
  final String status;
  final ReferredUser? referredUser;
  final String? registeredAt;

  const ReferralItem({
    required this.id,
    required this.referralCode,
    required this.rewardPoints,
    required this.status,
    this.referredUser,
    this.registeredAt,
  });

  factory ReferralItem.fromJson(Map<String, dynamic> json) {
    ReferredUser? user;
    if (json['referred_user'] is Map<String, dynamic>) {
      user = ReferredUser.fromJson(json['referred_user'] as Map<String, dynamic>);
    } else if (json.containsKey('name') || json.containsKey('phone') || json.containsKey('phone_masked')) {
      user = ReferredUser.fromJson(json);
    }

    return ReferralItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      referralCode: json['referral_code'] as String? ?? '',
      rewardPoints: json['reward_points'] as int? ??
          json['points'] as int? ??
          100,
      status: json['status'] as String? ?? 'successful',
      referredUser: user,
      registeredAt: json['registered_at'] as String? ?? json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'referral_code': referralCode,
        'reward_points': rewardPoints,
        'status': status,
        'referred_user': referredUser?.toJson(),
        'registered_at': registeredAt,
      };
}

/// Referral API Data wrapper
class ReferralData {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final int successfulReferrals;
  final int totalPointsEarned;
  final List<ReferralItem> items;

  const ReferralData({
    this.referralCode = '',
    this.referralLink = '',
    this.totalReferrals = 0,
    this.successfulReferrals = 0,
    this.totalPointsEarned = 0,
    this.items = const [],
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    List<ReferralItem> items = [];
    if (json['items'] is List) {
      items = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ReferralItem.fromJson(e))
          .toList();
    } else if (json['referred_users'] is List) {
      // Compatibility with legacy field
      items = (json['referred_users'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ReferralItem.fromJson(e))
          .toList();
    }

    return ReferralData(
      referralCode: json['referral_code'] as String? ?? '',
      referralLink: json['referral_link'] as String? ?? '',
      totalReferrals: json['total_referrals'] as int? ??
          json['total_invited'] as int? ??
          0,
      successfulReferrals: json['successful_referrals'] as int? ?? 0,
      totalPointsEarned: json['total_points_earned'] as int? ??
          json['earned_points'] as int? ??
          0,
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'referral_code': referralCode,
        'referral_link': referralLink,
        'total_referrals': totalReferrals,
        'successful_referrals': successfulReferrals,
        'total_points_earned': totalPointsEarned,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

/// Referral API Response Model
class ReferralResponse {
  final bool success;
  final String? message;
  final ReferralData data;
  final PaginationMeta meta;

  const ReferralResponse({
    this.success = false,
    this.message,
    this.data = const ReferralData(),
    this.meta = const PaginationMeta(),
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? json['status'] as bool? ?? false;
    final message = json['message'] as String?;

    ReferralData data = const ReferralData();
    if (json['data'] is Map<String, dynamic>) {
      data = ReferralData.fromJson(json['data'] as Map<String, dynamic>);
    }

    final meta = PaginationMeta.fromJson(
      json['meta'] as Map<String, dynamic>?,
    );

    return ReferralResponse(
      success: success,
      message: message,
      data: data,
      meta: meta,
    );
  }
}
