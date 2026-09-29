class ExamRankModel {
  final int rank;
  final String name;
  final String studentId;
  final String mark;
  final String correct;
  final String wrong;
  final String avoid;
  final bool isPassed;

  const ExamRankModel({
    required this.rank,
    required this.name,
    required this.studentId,
    required this.mark,
    required this.correct,
    required this.wrong,
    required this.avoid,
    required this.isPassed,
  });

  factory ExamRankModel.fromJson(Map<String, dynamic> json) {
    return ExamRankModel(
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? '1') ?? 1,
      name: json['name']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      mark: json['mark']?.toString() ?? '',
      correct: json['correct']?.toString() ?? '',
      wrong: json['wrong']?.toString() ?? '',
      avoid: json['avoid']?.toString() ?? '',
      isPassed: json['is_passed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'name': name,
      'student_id': studentId,
      'mark': mark,
      'correct': correct,
      'wrong': wrong,
      'avoid': avoid,
      'is_passed': isPassed,
    };
  }
}
