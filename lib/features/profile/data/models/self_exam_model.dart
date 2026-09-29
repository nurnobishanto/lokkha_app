class SelfExamModel {
  final String id;
  final String date;
  final String? duration;
  final String status;
  final bool isPassed;
  final String title;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final String obtainedMark;

  const SelfExamModel({
    required this.id,
    required this.date,
    this.duration,
    required this.status,
    required this.isPassed,
    required this.title,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.obtainedMark,
  });
}
