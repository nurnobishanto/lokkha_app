import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

abstract class QuickPracticeRepository {
  Future<List<QuickPracticeSubject>> getTopLevelSubjects({String? search});
  Future<SubjectChildrenResponse> getSubjectChildren(
    int subjectId, {
    int page = 1,
    int perPage = 24,
    String? search,
  });
  Future<SubjectQuestionsResponse> getSubjectQuestions(
    int subjectId, {
    int page = 1,
    int perPage = 15,
  });
}
