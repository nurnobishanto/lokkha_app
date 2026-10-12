import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/question_bank/data/models/bookmarked_question_model.dart';
import 'package:lokkha/features/question_bank/data/repositories/bookmark_repository.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class QuestionBankState {
  final List<BookmarkedQuestion> questions;
  final bool isLoading;
  final String selectedSubject;
  final String searchQuery;

  const QuestionBankState({
    this.questions = const [],
    this.isLoading = false,
    this.selectedSubject = 'সকল বিষয়',
    this.searchQuery = '',
  });

  QuestionBankState copyWith({
    List<BookmarkedQuestion>? questions,
    bool? isLoading,
    String? selectedSubject,
    String? searchQuery,
  }) {
    return QuestionBankState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<BookmarkedQuestion> get filteredQuestions {
    if (searchQuery.trim().isEmpty) {
      return questions;
    }
    final q = searchQuery.trim().toLowerCase();
    return questions.where((item) {
      return item.questionText.toLowerCase().contains(q) ||
          item.subject.toLowerCase().contains(q);
    }).toList();
  }
}

class QuestionBankNotifier extends Notifier<QuestionBankState> {
  final BookmarkRepository _repository = BookmarkRepository();

  static const List<String> subjects = [
    'সকল বিষয়',
    'বাংলা',
    'ইংরেজি',
    'গণিত',
    'বাংলাদেশ বিষয়াবলি',
    'আন্তর্জাতিক বিষয়াবলি',
    'বিজ্ঞান ও তথ্যপ্রযুক্তি',
  ];

  @override
  QuestionBankState build() {
    Future.microtask(fetchBookmarks);
    return const QuestionBankState();
  }

  Future<void> fetchBookmarks() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getBookmarks(
        subject: state.selectedSubject == 'সকল বিষয়'
            ? null
            : state.selectedSubject,
      );
      state = state.copyWith(questions: list, isLoading: false);
    } catch (e) {
      debugPrint('[QuestionBankNotifier] Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void onSubjectSelected(String subject) {
    state = state.copyWith(selectedSubject: subject);
    fetchBookmarks();
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> removeBookmark(int questionId) async {
    final success = await _repository.toggleBookmark(questionId);
    if (success) {
      final updated = List<BookmarkedQuestion>.from(state.questions)
        ..removeWhere((q) => q.id == questionId);
      state = state.copyWith(questions: updated);
      CustomSnackBar.showCustomToast(
        title: 'বুকমার্ক',
        message: 'প্রশ্নটি সেভড তালিকা থেকে মুছে ফেলা হয়েছে',
      );
    }
  }
}

final questionBankNotifierProvider =
    NotifierProvider<QuestionBankNotifier, QuestionBankState>(
  QuestionBankNotifier.new,
);
