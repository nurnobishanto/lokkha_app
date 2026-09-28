import 'package:flutter/foundation.dart';
import '../../../../../utils/constants.dart';
import '../../../../data/network/api_client.dart';
import '../models/blog_post_model.dart';

class BlogRepository {
  /// Fetch list of blog articles with optional category filter
  Future<List<BlogPost>> getBlogs({String? category}) async {
    try {
      final Map<String, dynamic> query = {};
      if (category != null && category != 'সকল আর্টিকেল') {
        query['category'] = category;
      }

      final response = await ApiClient.get(
        AppConstants.v1Blogs,
        queryParameters: query.isNotEmpty ? query : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data is List ? data : []);

        if (list.isNotEmpty) {
          return list
              .map((item) => BlogPost.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[BlogRepository] Error fetching blogs: $e');
    }

    // Offline fallback to sample posts
    return BlogPost.samplePosts;
  }

  /// Fetch single blog detail by slug or ID
  Future<BlogPost?> getBlogDetail(String idOrSlug) async {
    try {
      final response = await ApiClient.get('${AppConstants.v1Blogs}/$idOrSlug');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data'] as Map<String, dynamic>
            : response.data as Map<String, dynamic>;
        return BlogPost.fromJson(data);
      }
    } catch (e) {
      debugPrint('[BlogRepository] Error fetching blog detail: $e');
    }
    return BlogPost.samplePosts.firstWhere((p) => p.id == idOrSlug, orElse: () => BlogPost.samplePosts.first);
  }
}
