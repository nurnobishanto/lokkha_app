class ExamQuestionResultModel {
  final int questionNumber;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // 0 = A, 1 = B, 2 = C, 3 = D
  final int? userSelectedOptionIndex; // null if avoided
  final String? explanation;

  const ExamQuestionResultModel({
    required this.questionNumber,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.userSelectedOptionIndex,
    this.explanation,
  });

  bool get isCorrect => userSelectedOptionIndex != null && userSelectedOptionIndex == correctOptionIndex;
  bool get isAvoided => userSelectedOptionIndex == null;
  bool get isWrong => userSelectedOptionIndex != null && userSelectedOptionIndex != correctOptionIndex;
}
