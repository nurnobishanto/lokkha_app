import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

/// Reward points live balance and metrics
class RewardPointsBalance {
  final int balance;
  final int totalEarned;
  final int totalUsed;
  final int totalExpired;
  final int totalDeducted;

  const RewardPointsBalance({
    this.balance = 0,
    this.totalEarned = 0,
    this.totalUsed = 0,
    this.totalExpired = 0,
    this.totalDeducted = 0,
  });

  factory RewardPointsBalance.fromJson(Map<String, dynamic> json) {
    return RewardPointsBalance(
      balance: json['balance'] is int
          ? json['balance'] as int
          : int.tryParse(json['balance']?.toString() ?? '') ?? 0,
      totalEarned: json['total_earned'] is int
          ? json['total_earned'] as int
          : int.tryParse(json['total_earned']?.toString() ?? '') ?? 0,
      totalUsed: json['total_used'] is int
          ? json['total_used'] as int
          : int.tryParse(json['total_used']?.toString() ?? '') ?? 0,
      totalExpired: json['total_expired'] is int
          ? json['total_expired'] as int
          : int.tryParse(json['total_expired']?.toString() ?? '') ?? 0,
      totalDeducted: json['total_deducted'] is int
          ? json['total_deducted'] as int
          : int.tryParse(json['total_deducted']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'total_earned': totalEarned,
        'total_used': totalUsed,
        'total_expired': totalExpired,
        'total_deducted': totalDeducted,
      };
}

/// Reward Points Balance API Response
class RewardPointsResponse {
  final bool success;
  final String? message;
  final RewardPointsBalance data;

  const RewardPointsResponse({
    this.success = false,
    this.message,
    this.data = const RewardPointsBalance(),
  });

  factory RewardPointsResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? json['status'] as bool? ?? false;
    final message = json['message'] as String?;
    RewardPointsBalance data = const RewardPointsBalance();
    if (json['data'] is Map<String, dynamic>) {
      data = RewardPointsBalance.fromJson(json['data'] as Map<String, dynamic>);
    }

    return RewardPointsResponse(
      success: success,
      message: message,
      data: data,
    );
  }
}

/// Reward transaction history item
class RewardTransactionItem {
  final int id;
  final int points;
  final String type; // 'earned', 'used', 'expired', 'deducted'
  final String title;
  final String? description;
  final String? status;
  final String? createdAt;

  const RewardTransactionItem({
    required this.id,
    required this.points,
    required this.type,
    required this.title,
    this.description,
    this.status,
    this.createdAt,
  });

  bool get isEarned =>
      type.toLowerCase() == 'earned' ||
      type.toLowerCase() == 'credit' ||
      points > 0;

  factory RewardTransactionItem.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] ?? json['amount'] ?? json['reward_points'] ?? 0;
    final parsedPoints = rawPoints is int
        ? rawPoints
        : int.tryParse(rawPoints.toString()) ?? 0;

    final typeStr = json['type'] as String? ??
        (parsedPoints >= 0 ? 'earned' : 'used');

    return RewardTransactionItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      points: parsedPoints,
      type: typeStr,
      title: json['title'] as String? ??
          json['description'] as String? ??
          json['note'] as String? ??
          (typeStr == 'earned' ? 'পয়েন্ট অর্জন' : 'পয়েন্ট ব্যবহার'),
      description: json['description'] as String? ?? json['note'] as String?,
      status: json['status'] as String? ?? 'completed',
      createdAt: json['created_at'] as String? ?? json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'points': points,
        'type': type,
        'title': title,
        'description': description,
        'status': status,
        'created_at': createdAt,
      };
}

/// Reward Transactions API Response
class RewardTransactionsResponse {
  final bool success;
  final String? message;
  final List<RewardTransactionItem> items;
  final PaginationMeta meta;

  const RewardTransactionsResponse({
    this.success = false,
    this.message,
    this.items = const [],
    this.meta = const PaginationMeta(),
  });

  factory RewardTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? json['status'] as bool? ?? false;
    final message = json['message'] as String?;
    List<RewardTransactionItem> items = [];

    final rawData = json['data'];
    if (rawData is Map<String, dynamic> && rawData['items'] is List) {
      items = (rawData['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RewardTransactionItem.fromJson(e))
          .toList();
    } else if (rawData is List) {
      items = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => RewardTransactionItem.fromJson(e))
          .toList();
    } else if (json['items'] is List) {
      items = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RewardTransactionItem.fromJson(e))
          .toList();
    }

    final meta = PaginationMeta.fromJson(
      (json['meta'] as Map<String, dynamic>?) ??
          (rawData is Map<String, dynamic> ? rawData['meta'] as Map<String, dynamic>? : null),
    );

    return RewardTransactionsResponse(
      success: success,
      message: message,
      items: items,
      meta: meta,
    );
  }
}
