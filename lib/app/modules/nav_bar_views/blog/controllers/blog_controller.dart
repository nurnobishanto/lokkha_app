import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/blog_post_model.dart';
import '../../../../routes/app_pages.dart';

class BlogController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxList<BlogPost> allPosts = <BlogPost>[].obs;
  final RxString selectedCategory = 'সকল আর্টিকেল'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'নতুন আর্টিকেল প্রথমে'.obs;
  final RxBool showScrollToTop = false.obs;

  final List<String> categories = [
    'সকল আর্টিকেল',
    'BCS Preparation',
    'প্রাইমারি প্রধান শিক্ষক নিয়োগ',
    'ব্যাংক জব প্রস্তুতি',
    'এনটিআরসিএ শিক্ষক নিবন্ধন',
    'সাধারণ জ্ঞান ও সাম্প্রতিক',
    'বিসিএস লিখিত গাইডলাইন',
  ];

  final List<String> sortOptions = [
    'নতুন আর্টিকেল প্রথমে',
    'পুরাতন আর্টিকেল প্রথমে',
    'সর্বাধিক পঠিত',
  ];

  final List<String> newsTickerItems = [
    'অর্থবছর পরিবর্তন ও বাংলাদেশ',
    'The Victorian Period (1832-1901) MCQ: ২০০টি গুরুত্বপূর্ণ প্রশ্নোত্তর',
    'কম্পিউটার অপারেটিং সিস্টেম (Operating System) গুরুত্বপূর্ণ MCQ!',
    'The Neo-Classical Period (1660-1785)-এর ওপর গুরুত্বপূর্ণ MCQ',
  ];

  @override
  void onInit() {
    super.onInit();
    loadPosts();

    scrollController.addListener(() {
      if (scrollController.offset > 300 && !showScrollToTop.value) {
        showScrollToTop.value = true;
      } else if (scrollController.offset <= 300 && showScrollToTop.value) {
        showScrollToTop.value = false;
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void loadPosts() {
    allPosts.assignAll(BlogPost.samplePosts);
  }

  BlogPost? get featuredPost {
    return allPosts.firstWhereOrNull((p) => p.isFeatured) ??
        (allPosts.isNotEmpty ? allPosts.first : null);
  }

  List<BlogPost> get recentGuides {
    return allPosts.where((p) => p.isRecentGuide).toList();
  }

  List<BlogPost> get generalPosts {
    return allPosts.where((p) => !p.isFeatured && !p.isRecentGuide).toList();
  }

  List<BlogPost> get filteredPosts {
    List<BlogPost> result = List.from(allPosts);

    if (selectedCategory.value != 'সকল আর্টিকেল') {
      result = result
          .where((p) =>
              p.category.toLowerCase() ==
              selectedCategory.value.toLowerCase())
          .toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      result = result.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.excerpt.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedSort.value == 'পুরাতন আর্টিকেল প্রথমে') {
      result = result.reversed.toList();
    }

    return result;
  }

  void onCategorySelected(String category) {
    selectedCategory.value = category;
  }

  void onSearchSubmitted(String query) {
    searchQuery.value = query;
  }

  void onSortChanged(String? newSort) {
    if (newSort != null) {
      selectedSort.value = newSort;
    }
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void openPostDetails(BlogPost post) {
    Get.toNamed(Routes.BLOG_DETAILS, arguments: post);
  }

  void openCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'সকল ক্যাটেগরি',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B6B50),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Obx(() {
                        final isSelected = selectedCategory.value == cat;
                        return ListTile(
                          title: Text(
                            cat,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF1B6B50)
                                  : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF1B6B50))
                              : null,
                          onTap: () {
                            onCategorySelected(cat);
                            Navigator.pop(ctx);
                          },
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
