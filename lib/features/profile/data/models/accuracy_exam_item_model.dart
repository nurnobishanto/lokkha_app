class AccuracyExamItemModel {
  final String id;
  final String date;
  final String accuracy;
  final String status;
  final bool isPassed;
  final String title;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final String accuracyRatio;
  final String obtainedMark;

  const AccuracyExamItemModel({
    required this.id,
    required this.date,
    required this.accuracy,
    required this.status,
    required this.isPassed,
    required this.title,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracyRatio,
    required this.obtainedMark,
  });
}
