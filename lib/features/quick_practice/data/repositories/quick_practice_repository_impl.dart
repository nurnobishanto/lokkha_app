import 'package:lokkha/features/quick_practice/data/datasources/quick_practice_remote_data_source.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';
import 'package:lokkha/features/quick_practice/domain/repositories/quick_practice_repository.dart';

class QuickPracticeRepositoryImpl implements QuickPracticeRepository {
  final QuickPracticeRemoteDataSource _remoteDataSource;

  QuickPracticeRepositoryImpl({
    QuickPracticeRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? QuickPracticeRemoteDataSourceImpl();

  @override
  Future<List<QuickPracticeSubject>> getTopLevelSubjects({String? search}) {
    return _remoteDataSource.getTopLevelSubjects(search: search);
  }

  @override
  Future<SubjectChildrenResponse> getSubjectChildren(
    int subjectId, {
    int page = 1,
    int perPage = 24,
    String? search,
  }) {
    return _remoteDataSource.getSubjectChildren(
      subjectId,
      page: page,
      perPage: perPage,
      search: search,
    );
  }

  @override
  Future<SubjectQuestionsResponse> getSubjectQuestions(
    int subjectId, {
    int page = 1,
    int perPage = 15,
  }) {
    return _remoteDataSource.getSubjectQuestions(
      subjectId,
      page: page,
      perPage: perPage,
    );
  }
}
