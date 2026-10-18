import 'package:intl/intl.dart';
import 'exam_history_model.dart';

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

  factory AccuracyExamItemModel.empty() {
    return const AccuracyExamItemModel(
      id: '',
      date: '',
      accuracy: '0%',
      status: '',
      isPassed: false,
      title: '',
      totalQuestions: 0,
      correctCount: 0,
      wrongCount: 0,
      accuracyRatio: '0%',
      obtainedMark: '0',
    );
  }

  factory AccuracyExamItemModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? '';
    final cleanId = rawId.replaceAll('#', '').trim();

    // Date formatting
    final rawDate = json['submitted_at']?.toString() ??
        json['created_at']?.toString() ??
        json['date']?.toString() ??
        '';
    String formattedDate = rawDate;
    if (rawDate.isNotEmpty) {
      try {
        final parsed = DateTime.tryParse(rawDate);
        if (parsed != null) {
          formattedDate = DateFormat("d MMM, yyyy • hh:mm a").format(parsed);
        }
      } catch (_) {}
    }

    // Accuracy %
    final accVal = json['accuracy_percent'] ??
        json['accuracy_rate'] ??
        json['accuracy'] ??
        json['score_percent'];
    String accStr = '0%';
    if (accVal != null) {
      if (accVal is num) {
        accStr = accVal % 1 == 0 ? '${accVal.toInt()}%' : '${accVal.toStringAsFixed(1)}%';
      } else {
        final s = accVal.toString();
        accStr = s.endsWith('%') ? s : '$s%';
      }
    }

    // Status
    final statusStr = json['result_status']?.toString() ??
        json['status']?.toString() ??
        'Completed';
    final passed = json['is_passed'] == true ||
        statusStr.toLowerCase().contains('pass') ||
        statusStr.toLowerCase() == 'completed';

    // Title
    final titleStr = json['exam_title']?.toString() ??
        json['title']?.toString() ??
        'পরীক্ষা';

    // Questions count
    final totalQ = json['total_questions'] is int
        ? json['total_questions'] as int
        : int.tryParse(json['total_questions']?.toString() ?? '0') ?? 0;

    final correct = json['correct_answers'] is int
        ? json['correct_answers'] as int
        : (json['correct_count'] is int
            ? json['correct_count'] as int
            : int.tryParse(json['correct_answers']?.toString() ??
                    json['correct_count']?.toString() ??
                    '0') ??
                0);

    final wrong = json['incorrect_answers'] is int
        ? json['incorrect_answers'] as int
        : (json['wrong_count'] is int
            ? json['wrong_count'] as int
            : int.tryParse(json['incorrect_answers']?.toString() ??
                    json['wrong_count']?.toString() ??
                    '0') ??
                0);

    // Score
    final score = json['score']?.toString() ??
        json['obtained_mark']?.toString() ??
        '$correct';

    return AccuracyExamItemModel(
      id: cleanId,
      date: formattedDate,
      accuracy: accStr,
      status: statusStr,
      isPassed: passed,
      title: titleStr,
      totalQuestions: totalQ,
      correctCount: correct,
      wrongCount: wrong,
      accuracyRatio: accStr,
      obtainedMark: score,
    );
  }

  factory AccuracyExamItemModel.fromExam(ExamHistoryModel exam) {
    return AccuracyExamItemModel(
      id: exam.numericId.toString(),
      date: exam.date,
      accuracy: "${exam.scorePercent.toStringAsFixed(0)}%",
      status: exam.resultStatus.isNotEmpty ? exam.resultStatus : "Completed",
      isPassed: exam.isPassed,
      title: exam.title,
      totalQuestions: exam.totalQuestions,
      correctCount: exam.correctCount,
      wrongCount: exam.wrongCount,
      accuracyRatio: "${exam.scorePercent.toStringAsFixed(0)}%",
      obtainedMark: exam.obtainedMark,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'accuracy': accuracy,
        'status': status,
        'is_passed': isPassed,
        'title': title,
        'total_questions': totalQuestions,
        'correct_count': correctCount,
        'wrong_count': wrongCount,
        'accuracy_ratio': accuracyRatio,
        'obtained_mark': obtainedMark,
      };
}
