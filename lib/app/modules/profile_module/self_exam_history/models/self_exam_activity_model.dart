class SelfExamActivityModel {
  final String time;
  final int totalQuestions;
  final String totalMark;
  final String positiveMark;
  final String studentName;
  final String studentId;
  final String fullMark;
  final String yourMark;
  final String attempt;
  final String avoid;
  final String correct;
  final String wrong;

  const SelfExamActivityModel({
    required this.time,
    required this.totalQuestions,
    required this.totalMark,
    required this.positiveMark,
    required this.studentName,
    required this.studentId,
    required this.fullMark,
    required this.yourMark,
    required this.attempt,
    required this.avoid,
    required this.correct,
    required this.wrong,
  });
}
