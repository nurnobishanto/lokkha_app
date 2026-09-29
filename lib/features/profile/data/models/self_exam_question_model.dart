class SelfExamQuestionModel {
  final int questionNumber;
  final String questionText;
  final List<String> options;
  final String? yourAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? explanation;

  const SelfExamQuestionModel({
    required this.questionNumber,
    required this.questionText,
    required this.options,
    this.yourAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.explanation,
  });
}
