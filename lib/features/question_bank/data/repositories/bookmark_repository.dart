import 'package:flutter/foundation.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/question_bank/question_bank.dart';

class BookmarkRepository {
  /// Fetch all saved/bookmarked questions
  Future<List<BookmarkedQuestion>> getBookmarks({String? subject}) async {
    try {
      final Map<String, dynamic> query = {};
      if (subject != null && subject.isNotEmpty && subject != 'সকল বিষয়') {
        query['subject'] = subject;
      }

      final response = await ApiClient.get(
        AppConstants.v1Bookmarks,
        queryParameters: query.isNotEmpty ? query : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data is List ? data : []);

        return list
            .map((item) => BookmarkedQuestion.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[BookmarkRepository] Error fetching bookmarks: $e');
    }
    return [];
  }

  /// Toggle bookmark status for a question (Add / Remove)
  Future<bool> toggleBookmark(int questionId) async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1BookmarkToggle,
        data: {'question_id': questionId},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[BookmarkRepository] Error toggling bookmark: $e');
      return false;
    }
  }
}
