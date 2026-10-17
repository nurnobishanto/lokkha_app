import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/question_bank_provider.dart';
import 'package:lokkha/features/question_bank/data/models/random_question_model.dart';

class RandomQuestionState {
  final RandomQuestionModel? question;
  final bool isLoading;
  final String? errorMessage;
  final int? selectedOptionIndex;
  final bool isAnswerRevealed;
  final bool isExplanationExpanded;

  const RandomQuestionState({
    this.question,
    this.isLoading = false,
    this.errorMessage,
    this.selectedOptionIndex,
    this.isAnswerRevealed = false,
    this.isExplanationExpanded = false,
  });

  RandomQuestionState copyWith({
    RandomQuestionModel? question,
    bool? isLoading,
    String? errorMessage,
    int? selectedOptionIndex,
    bool? isAnswerRevealed,
    bool? isExplanationExpanded,
    bool clearSelectedOption = false,
  }) {
    return RandomQuestionState(
      question: question ?? this.question,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedOptionIndex: clearSelectedOption
          ? null
          : (selectedOptionIndex ?? this.selectedOptionIndex),
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      isExplanationExpanded:
          isExplanationExpanded ?? this.isExplanationExpanded,
    );
  }
}

class RandomQuestionNotifier extends Notifier<RandomQuestionState> {
  @override
  RandomQuestionState build() {
    return const RandomQuestionState(isLoading: false);
  }

  Future<void> fetchRandomQuestion({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearSelectedOption: true,
      isAnswerRevealed: false,
      isExplanationExpanded: false,
    );

    try {
      final useCase = ref.read(getRandomQuestionUseCaseProvider);
      final question = await useCase();

      if (question != null) {
        state = state.copyWith(
          question: question,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'প্রশ্ন লোড করা সম্ভব হয়নি।',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  void selectOption(int index) {
    if (state.isAnswerRevealed) return; // Prevent changing after revealing
    state = state.copyWith(
      selectedOptionIndex: index,
      isAnswerRevealed: true,
    );
  }

  void toggleExplanation() {
    state = state.copyWith(
      isExplanationExpanded: !state.isExplanationExpanded,
    );
  }

  void resetSelection() {
    state = state.copyWith(
      clearSelectedOption: true,
      isAnswerRevealed: false,
      isExplanationExpanded: false,
    );
  }
}

final randomQuestionNotifierProvider =
    NotifierProvider<RandomQuestionNotifier, RandomQuestionState>(
  RandomQuestionNotifier.new,
);
