import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/question_bank/question_bank.dart';

class QuestionBankController extends GetxController {
  final BookmarkRepository _repository = BookmarkRepository();

  final RxList<BookmarkedQuestion> questions = <BookmarkedQuestion>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedSubject = 'সকল বিষয়'.obs;
  final RxString searchQuery = ''.obs;

  final List<String> subjects = [
    'সকল বিষয়',
    'বাংলা',
    'ইংরেজি',
    'গণিত',
    'বাংলাদেশ বিষয়াবলি',
    'আন্তর্জাতিক বিষয়াবলি',
    'বিজ্ঞান ও তথ্যপ্রযুক্তি',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    isLoading.value = true;
    try {
      final list = await _repository.getBookmarks(
        subject: selectedSubject.value == 'সকল বিষয়' ? null : selectedSubject.value,
      );
      questions.assignAll(list);
    } catch (e) {
      debugPrint('[QuestionBankController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSubjectSelected(String subject) {
    selectedSubject.value = subject;
    fetchBookmarks();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  Future<void> removeBookmark(int questionId) async {
    final success = await _repository.toggleBookmark(questionId);
    if (success) {
      questions.removeWhere((q) => q.id == questionId);
      Get.snackbar(
        'বুকমার্ক',
        'প্রশ্নটি সেভড তালিকা থেকে মুছে ফেলা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  List<BookmarkedQuestion> get filteredQuestions {
    if (searchQuery.value.trim().isEmpty) {
      return questions;
    }
    final q = searchQuery.value.trim().toLowerCase();
    return questions.where((item) {
      return item.questionText.toLowerCase().contains(q) ||
          item.subject.toLowerCase().contains(q);
    }).toList();
  }
}
