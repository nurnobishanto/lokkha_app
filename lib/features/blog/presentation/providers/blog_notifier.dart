import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/blog/data/models/blog_post_model.dart';
import 'package:lokkha/features/blog/data/repositories/blog_repository.dart';

class BlogState {
  final List<BlogPost> allPosts;
  final bool isLoading;
  final String selectedCategory;
  final String searchQuery;
  final String selectedSort;

  const BlogState({
    this.allPosts = const [],
    this.isLoading = false,
    this.selectedCategory = 'সকল আর্টিকেল',
    this.searchQuery = '',
    this.selectedSort = 'নতুন আর্টিকেল প্রথমে',
  });

  BlogState copyWith({
    List<BlogPost>? allPosts,
    bool? isLoading,
    String? selectedCategory,
    String? searchQuery,
    String? selectedSort,
  }) {
    return BlogState(
      allPosts: allPosts ?? this.allPosts,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSort: selectedSort ?? this.selectedSort,
    );
  }

  BlogPost? get featuredPost {
    return allPosts.cast<BlogPost?>().firstWhere(
          (p) => p?.isFeatured == true,
          orElse: () => allPosts.isNotEmpty ? allPosts.first : null,
        );
  }

  List<BlogPost> get recentGuides {
    return allPosts.where((p) => p.isRecentGuide).toList();
  }

  List<BlogPost> get generalPosts {
    return allPosts.where((p) => !p.isFeatured && !p.isRecentGuide).toList();
  }

  List<BlogPost> get filteredPosts {
    List<BlogPost> result = List.from(allPosts);

    if (selectedCategory != 'সকল আর্টিকেল') {
      result = result
          .where((p) =>
              p.category.toLowerCase() == selectedCategory.toLowerCase())
          .toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.excerpt.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedSort == 'পুরাতন আর্টিকেল প্রথমে') {
      result = result.reversed.toList();
    }

    return result;
  }
}

class BlogNotifier extends Notifier<BlogState> {
  final BlogRepository _repository = BlogRepository();

  static const List<String> categories = [
    'সকল আর্টিকেল',
    'BCS Preparation',
    'প্রাইমারি প্রধান শিক্ষক নিয়োগ',
    'ব্যাংক জব প্রস্তুতি',
    'এনটিআরসিএ শিক্ষক নিবন্ধন',
    'সাধারণ জ্ঞান ও সাম্প্রতিক',
    'বিসিএস লিখিত গাইডলাইন',
  ];

  static const List<String> sortOptions = [
    'নতুন আর্টিকেল প্রথমে',
    'পুরাতন আর্টিকেল প্রথমে',
    'সর্বাধিক পঠিত',
  ];

  @override
  BlogState build() {
    Future.microtask(loadPosts);
    return const BlogState();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true);
    try {
      final posts = await _repository.getBlogs(
        category: state.selectedCategory == 'সকল আর্টিকেল'
            ? null
            : state.selectedCategory,
      );
      state = state.copyWith(allPosts: posts, isLoading: false);
    } catch (e) {
      debugPrint("Error loading blog posts: $e");
      state = state.copyWith(
        allPosts: BlogPost.samplePosts,
        isLoading: false,
      );
    }
  }

  void onCategorySelected(String category) {
    state = state.copyWith(selectedCategory: category);
    loadPosts();
  }

  void onSearchSubmitted(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void onSortChanged(String? newSort) {
    if (newSort != null) {
      state = state.copyWith(selectedSort: newSort);
    }
  }
}

final blogNotifierProvider =
    NotifierProvider<BlogNotifier, BlogState>(BlogNotifier.new);
