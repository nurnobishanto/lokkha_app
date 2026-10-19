import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

abstract class QuickPracticeRemoteDataSource {
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

class QuickPracticeRemoteDataSourceImpl implements QuickPracticeRemoteDataSource {
  final RestClient _client;

  QuickPracticeRemoteDataSourceImpl({RestClient? client})
      : _client = client ?? RestClient();

  @override
  Future<List<QuickPracticeSubject>> getTopLevelSubjects({String? search}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _client.get(
      Endpoints.subjectSectionsSubjects,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final parsed = QuickPracticeSubjectsResponse.fromJson(response.data);
    return parsed.subjects;
  }

  @override
  Future<SubjectChildrenResponse> getSubjectChildren(
    int subjectId, {
    int page = 1,
    int perPage = 24,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _client.get(
      Endpoints.subjectSectionsChildren(subjectId),
      queryParameters: queryParams,
    );

    if (response.data is Map<String, dynamic>) {
      return SubjectChildrenResponse.fromJson(response.data as Map<String, dynamic>);
    }
    return const SubjectChildrenResponse();
  }

  @override
  Future<SubjectQuestionsResponse> getSubjectQuestions(
    int subjectId, {
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _client.get(
      Endpoints.subjectSectionsQuestions(subjectId),
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    if (response.data is Map<String, dynamic>) {
      return SubjectQuestionsResponse.fromJson(response.data as Map<String, dynamic>);
    }
    return const SubjectQuestionsResponse();
  }
}
