class AccuracyMetricModel {
  final String avgAccuracy;
  final String highestAccuracy;
  final int totalQuestionsAnswered;
  final int correctCount;
  final int wrongCount;

  const AccuracyMetricModel({
    required this.avgAccuracy,
    required this.highestAccuracy,
    required this.totalQuestionsAnswered,
    required this.correctCount,
    required this.wrongCount,
  });
}
