class ExamHistoryModel {
  final String id;
  final String date;
  final String status;
  final bool isPassed;
  final String title;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final String obtainedMark;

  const ExamHistoryModel({
    required this.id,
    required this.date,
    required this.status,
    this.isPassed = false,
    required this.title,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.obtainedMark,
  });

  factory ExamHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExamHistoryModel(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isPassed: json['is_passed'] == true,
      title: json['title']?.toString() ?? '',
      totalQuestions: json['total_questions'] is int
          ? json['total_questions']
          : int.tryParse(json['total_questions']?.toString() ?? '0') ?? 0,
      correctCount: json['correct_count'] is int
          ? json['correct_count']
          : int.tryParse(json['correct_count']?.toString() ?? '0') ?? 0,
      wrongCount: json['wrong_count'] is int
          ? json['wrong_count']
          : int.tryParse(json['wrong_count']?.toString() ?? '0') ?? 0,
      obtainedMark: json['obtained_mark']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'status': status,
      'is_passed': isPassed,
      'title': title,
      'total_questions': totalQuestions,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'obtained_mark': obtainedMark,
    };
  }
}
