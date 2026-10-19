import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

abstract class QuickPracticeRemoteDataSource {
  Future<List<SubjectSectionOverview>> getSubjectSectionsOverview();
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
  Future<SubjectExamSession> startSubjectExam(
    int subjectId,
    SubjectStartExamRequest request,
  );
}

class QuickPracticeRemoteDataSourceImpl implements QuickPracticeRemoteDataSource {
  final RestClient _client;

  QuickPracticeRemoteDataSourceImpl({RestClient? client})
      : _client = client ?? RestClient();

  @override
  Future<List<SubjectSectionOverview>> getSubjectSectionsOverview() async {
    final response = await _client.get(Endpoints.subjectSectionsOverview);

    if (response.data is Map<String, dynamic>) {
      final rawData = response.data['data'] ?? response.data['sections'];
      if (rawData is List) {
        return rawData
            .map((e) =>
                SubjectSectionOverview.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else if (response.data is List) {
      return (response.data as List)
          .map((e) =>
              SubjectSectionOverview.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

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

  @override
  Future<SubjectExamSession> startSubjectExam(
    int subjectId,
    SubjectStartExamRequest request,
  ) async {
    final response = await _client.post(
      Endpoints.subjectSectionsStartExam(subjectId),
      data: request.toJson(),
    );

    if (response.data is Map<String, dynamic>) {
      return SubjectExamSession.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to generate practice test.');
  }
}
