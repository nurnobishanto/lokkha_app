class ContestHistoryItemModel {
  final String id;
  final String date;
  final String? duration;
  final String title;
  final int correctCount;
  final int wrongCount;

  const ContestHistoryItemModel({
    required this.id,
    required this.date,
    this.duration,
    required this.title,
    required this.correctCount,
    required this.wrongCount,
  });
}
