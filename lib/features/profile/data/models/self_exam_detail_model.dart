import 'self_exam_model.dart';
import 'self_exam_question_model.dart';

class SelfExamDetailModel {
  final SelfExamModel exam;
  final List<SelfExamQuestionModel> questions;

  const SelfExamDetailModel({
    required this.exam,
    this.questions = const [],
  });

  factory SelfExamDetailModel.fromJson(dynamic json, {SelfExamModel? summaryExam}) {
    Map<String, dynamic> dataMap = {};
    if (json is Map<String, dynamic>) {
      if (json['data'] is Map<String, dynamic>) {
        dataMap = json['data'] as Map<String, dynamic>;
      } else {
        dataMap = json;
      }
    }

    final examData = SelfExamModel.fromJson(dataMap);

    List<SelfExamQuestionModel> questionsList = [];
    final rawQuestions = dataMap['questions'];
    if (rawQuestions is List) {
      for (int i = 0; i < rawQuestions.length; i++) {
        final q = rawQuestions[i];
        if (q is Map<String, dynamic>) {
          questionsList.add(SelfExamQuestionModel.fromJson(q, index: i + 1));
        }
      }
    }

    return SelfExamDetailModel(
      exam: summaryExam != null
          ? SelfExamModel(
              id: examData.id.isNotEmpty ? examData.id : summaryExam.id,
              rawId: examData.rawId ?? summaryExam.rawId,
              type: examData.type ?? summaryExam.type,
              isExam: examData.isExam,
              totalQuestions: examData.totalQuestions > 0 ? examData.totalQuestions : summaryExam.totalQuestions,
              correctCount: examData.correctCount > 0 ? examData.correctCount : summaryExam.correctCount,
              wrongCount: examData.wrongCount > 0 ? examData.wrongCount : summaryExam.wrongCount,
              attempted: examData.attempted > 0 ? examData.attempted : summaryExam.attempted,
              avoided: examData.avoided > 0 ? examData.avoided : summaryExam.avoided,
              positiveMark: examData.positiveMark,
              negativeMark: examData.negativeMark,
              score: examData.score > 0 ? examData.score : summaryExam.score,
              totalMarks: examData.totalMarks > 0 ? examData.totalMarks : summaryExam.totalMarks,
              scorePercent: examData.scorePercent > 0 ? examData.scorePercent : summaryExam.scorePercent,
              resultStatus: examData.resultStatus.isNotEmpty ? examData.resultStatus : summaryExam.resultStatus,
              selectDuration: examData.selectDuration ?? summaryExam.selectDuration,
              completeDuration: examData.completeDuration ?? summaryExam.completeDuration,
              createdAt: examData.createdAt.isNotEmpty ? examData.createdAt : summaryExam.createdAt,
              title: summaryExam.title,
            )
          : examData,
      questions: questionsList,
    );
  }
}
