import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/features/profile/profile.dart';

void main() {
  group('Referral V1 Models Tests', () {
    test('ReferralResponse parses exact user prompt payload correctly', () {
      final json = {
        "success": true,
        "message": "Referral details and history retrieved successfully.",
        "data": {
          "items": [
            {
              "id": 19,
              "referral_code": "LK9A8B7C",
              "reward_points": 100,
              "status": "successful",
              "referred_user": {
                "name": "Tanvir Hasan",
                "phone_masked": "018****491"
              },
              "registered_at": "2026-09-12 18:22:15"
            }
          ],
          "referral_code": "LK9A8B7C",
          "referral_link": "https://lokkha.com/register?ref=LK9A8B7C",
          "total_referrals": 12,
          "successful_referrals": 10,
          "total_points_earned": 1000
        },
        "meta": {"current_page": 1, "last_page": 1, "total": 12}
      };

      final response = ReferralResponse.fromJson(json);

      expect(response.success, true);
      expect(response.message,
          "Referral details and history retrieved successfully.");
      expect(response.data.referralCode, "LK9A8B7C");
      expect(response.data.referralLink,
          "https://lokkha.com/register?ref=LK9A8B7C");
      expect(response.data.totalReferrals, 12);
      expect(response.data.successfulReferrals, 10);
      expect(response.data.totalPointsEarned, 1000);
      expect(response.data.items.length, 1);

      final item = response.data.items.first;
      expect(item.id, 19);
      expect(item.referralCode, "LK9A8B7C");
      expect(item.rewardPoints, 100);
      expect(item.status, "successful");
      expect(item.referredUser?.name, "Tanvir Hasan");
      expect(item.referredUser?.phoneMasked, "018****491");
      expect(item.registeredAt, "2026-09-12 18:22:15");

      expect(response.meta.currentPage, 1);
      expect(response.meta.lastPage, 1);
      expect(response.meta.total, 12);
    });

    test('ReferralResponse handles backward-compatible keys seamlessly', () {
      final json = {
        "success": true,
        "message": "Referral details",
        "data": {
          "total_invited": 5,
          "earned_points": 500,
          "items": [
            {
              "id": "1",
              "name": "Rahim",
              "phone": "01700000000",
              "date": "2026-01-01",
              "points": 100
            }
          ]
        }
      };

      final response = ReferralResponse.fromJson(json);
      expect(response.data.totalReferrals, 5);
      expect(response.data.totalPointsEarned, 500);
      expect(response.data.items.length, 1);
      expect(response.data.items.first.referredUser?.name, "Rahim");
    });
  });

  group('Reward Points V1 Models Tests', () {
    test('RewardPointsResponse parses balance and metrics successfully', () {
      final json = {
        "success": true,
        "message": "Reward points balance and metrics retrieved successfully.",
        "data": {
          "balance": 1340,
          "total_earned": 1500,
          "total_used": 100,
          "total_expired": 60,
          "total_deducted": 0
        }
      };

      final response = RewardPointsResponse.fromJson(json);

      expect(response.success, true);
      expect(response.message,
          "Reward points balance and metrics retrieved successfully.");
      expect(response.data.balance, 1340);
      expect(response.data.totalEarned, 1500);
      expect(response.data.totalUsed, 100);
      expect(response.data.totalExpired, 60);
      expect(response.data.totalDeducted, 0);
    });

    test('RewardTransactionsResponse parses ledger items and metadata', () {
      final json = {
        "success": true,
        "message": "Transactions retrieved",
        "data": {
          "items": [
            {
              "id": 101,
              "type": "earned",
              "points": 100,
              "title": "রেফারেল বোনাস",
              "description": "Tanvir Hasan এর সফল রেজিস্ট্রেশন",
              "created_at": "2026-09-12 18:22:15"
            },
            {
              "id": 102,
              "type": "used",
              "points": -50,
              "title": "কোর্স ডিসকাউন্ট",
              "description": "BCS প্রিলি কোর্সে ডিসকাউন্ট রিডিম",
              "created_at": "2026-09-13 10:00:00"
            }
          ]
        },
        "meta": {"current_page": 1, "last_page": 2, "total": 20}
      };

      final response = RewardTransactionsResponse.fromJson(json);
      expect(response.success, true);
      expect(response.items.length, 2);

      final item1 = response.items[0];
      expect(item1.id, 101);
      expect(item1.isEarned, true);
      expect(item1.points, 100);
      expect(item1.title, "রেফারেল বোনাস");

      final item2 = response.items[1];
      expect(item2.id, 102);
      expect(item2.isEarned, false);
      expect(item2.points, -50);
      expect(item2.title, "কোর্স ডিসকাউন্ট");

      expect(response.meta.currentPage, 1);
      expect(response.meta.lastPage, 2);
      expect(response.meta.total, 20);
    });
  });

  group('Endpoints and Routes Configuration', () {
    test('Reward Points & Referral endpoints and routes are properly configured',
        () {
      expect(Endpoints.rewardPoints, '/api/v1/user/reward-points');
      expect(Endpoints.rewardTransactions,
          '/api/v1/user/reward-points/transactions');
      expect(Endpoints.referrals, '/api/v1/user/referrals');
      expect(Routes.rewardPoints, '/reward-points');
      expect(Routes.referral, '/referral');
    });
  });

  group('RewardPointsState Tab filtering logic', () {
    test('RewardPointsState default values and copyWith work as expected', () {
      const state = RewardPointsState();
      expect(state.currentTab, 'all');
      expect(state.balance.balance, 0);
      expect(state.isLoading, true);
      expect(state.transactions, isEmpty);

      final updated = state.copyWith(
        currentTab: 'earned',
        balance: const RewardPointsBalance(
          balance: 1340,
          totalEarned: 1500,
          totalUsed: 100,
          totalExpired: 60,
          totalDeducted: 0,
        ),
      );

      expect(updated.currentTab, 'earned');
      expect(updated.balance.balance, 1340);
      expect(updated.balance.totalEarned, 1500);
    });
  });
}
