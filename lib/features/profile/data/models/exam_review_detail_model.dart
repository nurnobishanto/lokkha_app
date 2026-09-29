import 'exam_history_model.dart';
import 'exam_question_result_model.dart';

class ExamReviewDetailModel {
  final int id;
  final int? examId;
  final String examTitle;
  final double score;
  final double totalMarks;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int avoided;
  final String? timeTaken;
  final int? rank;
  final String resultStatus;
  final String submittedAt;
  final List<ExamQuestionResultModel> questions;

  const ExamReviewDetailModel({
    required this.id,
    this.examId,
    required this.examTitle,
    this.score = 0.0,
    this.totalMarks = 0.0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.avoided = 0,
    this.timeTaken,
    this.rank,
    this.resultStatus = '',
    this.submittedAt = '',
    this.questions = const [],
  });

  factory ExamReviewDetailModel.fromJson(
    dynamic json, {
    ExamHistoryModel? summaryExam,
  }) {
    Map<String, dynamic> dataMap = {};
    List<dynamic> rawQuestions = [];

    if (json is Map<String, dynamic>) {
      if (json['data'] is Map<String, dynamic>) {
        dataMap = json['data'] as Map<String, dynamic>;
      } else if (json['data'] is List) {
        rawQuestions = json['data'] as List;
      } else {
        dataMap = json;
      }
    }

    if (rawQuestions.isEmpty) {
      if (dataMap['questions'] is List) {
        rawQuestions = dataMap['questions'] as List;
      } else if (dataMap['items'] is List) {
        rawQuestions = dataMap['items'] as List;
      } else if (dataMap['results'] is List) {
        rawQuestions = dataMap['results'] as List;
      } else if (dataMap['review'] is List) {
        rawQuestions = dataMap['review'] as List;
      } else if (dataMap['answers'] is List) {
        rawQuestions = dataMap['answers'] as List;
      }
    }

    final questionsList = <ExamQuestionResultModel>[];
    for (int i = 0; i < rawQuestions.length; i++) {
      final qItem = rawQuestions[i];
      if (qItem is Map<String, dynamic>) {
        questionsList.add(ExamQuestionResultModel.fromJson(qItem, index: i + 1));
      }
    }

    final examSummary = dataMap['exam'] is Map<String, dynamic>
        ? dataMap['exam'] as Map<String, dynamic>
        : dataMap;

    final idVal = examSummary['id'] is int
        ? examSummary['id'] as int
        : (summaryExam?.rawId ??
            int.tryParse(examSummary['id']?.toString() ?? '') ??
            summaryExam?.numericId ??
            0);

    final titleVal = examSummary['exam_title']?.toString() ??
        examSummary['title']?.toString() ??
        summaryExam?.title ??
        '';

    final scoreVal = examSummary['score'] is num
        ? (examSummary['score'] as num).toDouble()
        : (summaryExam != null
            ? summaryExam.score
            : double.tryParse(examSummary['score']?.toString() ?? '0.0') ??
                0.0);

    final totalMarksVal = examSummary['total_marks'] is num
        ? (examSummary['total_marks'] as num).toDouble()
        : (summaryExam != null
            ? summaryExam.totalMarks
            : double.tryParse(examSummary['total_marks']?.toString() ?? '0.0') ??
                0.0);

    final totalQuestionsVal = examSummary['total_questions'] is int
        ? examSummary['total_questions'] as int
        : (summaryExam != null && summaryExam.totalQuestions > 0
            ? summaryExam.totalQuestions
            : (questionsList.isNotEmpty
                ? questionsList.length
                : int.tryParse(
                        examSummary['total_questions']?.toString() ?? '0') ??
                    0));

    final correctVal = examSummary['correct_answers'] is int
        ? examSummary['correct_answers'] as int
        : (summaryExam != null
            ? summaryExam.correctCount
            : int.tryParse(
                    examSummary['correct_answers']?.toString() ?? '0') ??
                questionsList.where((q) => q.isCorrect).length);

    final incorrectVal = examSummary['incorrect_answers'] is int
        ? examSummary['incorrect_answers'] as int
        : (summaryExam != null
            ? summaryExam.wrongCount
            : int.tryParse(
                    examSummary['incorrect_answers']?.toString() ?? '0') ??
                questionsList.where((q) => q.isWrong).length);

    final avoidedVal = examSummary['avoided'] is int
        ? examSummary['avoided'] as int
        : (summaryExam != null
            ? summaryExam.avoided
            : int.tryParse(examSummary['avoided']?.toString() ?? '0') ??
                questionsList.where((q) => q.isAvoided).length);

    return ExamReviewDetailModel(
      id: idVal,
      examId: examSummary['exam_id'] is int
          ? examSummary['exam_id'] as int
          : summaryExam?.examId,
      examTitle: titleVal,
      score: scoreVal,
      totalMarks: totalMarksVal,
      totalQuestions: totalQuestionsVal,
      correctAnswers: correctVal,
      incorrectAnswers: incorrectVal,
      avoided: avoidedVal,
      timeTaken: examSummary['time_taken']?.toString() ??
          examSummary['duration']?.toString(),
      rank: examSummary['rank'] is int
          ? examSummary['rank'] as int
          : int.tryParse(examSummary['rank']?.toString() ?? ''),
      resultStatus: examSummary['result_status']?.toString() ??
          summaryExam?.resultStatus ??
          '',
      submittedAt: examSummary['submitted_at']?.toString() ??
          summaryExam?.submittedAt ??
          '',
      questions: questionsList,
    );
  }
}
