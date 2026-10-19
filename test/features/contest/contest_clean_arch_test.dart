import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/shared/models/contest.dart' as shared;
import 'package:lokkha/shared/models/question.dart';

class _FakeRestClient extends RestClient {
  Map<String, dynamic>? getResponseData;
  Map<String, dynamic>? postResponseData;
  String? lastGetPath;
  String? lastPostPath;
  dynamic lastPostData;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastGetPath = path;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: getResponseData as T?,
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPostPath = path;
    lastPostData = data;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: postResponseData as T?,
      statusCode: 200,
    );
  }
}

class _MockContestRepository implements ContestRepository {
  LatestContestModel? latestContestToReturn;
  AllContestModel? allContestsToReturn;
  ContestResultModel? latestResultToReturn;
  ContestStartModel? startContestToReturn;
  ContestSubmitModel? submitContestToReturn;
  bool shouldThrow = false;

  @override
  Future<LatestContestModel?> getLatestContest() async {
    if (shouldThrow) throw Exception('Latest contest error');
    return latestContestToReturn;
  }

  @override
  Future<AllContestModel?> getAllContests() async {
    if (shouldThrow) throw Exception('All contests error');
    return allContestsToReturn;
  }

  @override
  Future<ContestResultModel?> getLatestContestResult() async {
    if (shouldThrow) throw Exception('Contest result error');
    return latestResultToReturn;
  }

  @override
  Future<ContestStartModel?> startContest(int contestId) async {
    if (shouldThrow) throw Exception('Start contest error');
    return startContestToReturn;
  }

  @override
  Future<ContestSubmitModel?> submitContest({
    required int contestId,
    required List<Map<String, dynamic>> userAnswers,
  }) async {
    if (shouldThrow) throw Exception('Submit contest error');
    return submitContestToReturn;
  }
}

void main() {
  group('Contest Clean Architecture - RemoteDataSource & Repository', () {
    late _FakeRestClient fakeClient;
    late ContestRemoteDataSource remoteDataSource;
    late ContestRepository repository;

    setUp(() {
      fakeClient = _FakeRestClient();
      remoteDataSource = ContestRemoteDataSourceImpl(client: fakeClient);
      repository = ContestRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test('getLatestContest queries Endpoints.latestContest and parses result', () async {
      fakeClient.getResponseData = {
        'status': true,
        'contest': {
          'id': 1,
          'name': 'বিসিএস লাইভ কনটেস্ট ১',
          'duration': 60,
        },
      };

      final result = await repository.getLatestContest();
      expect(result, isNotNull);
      expect(result?.status, true);
      expect(result?.contest?.id, 1);
      expect(result?.contest?.name, 'বিসিএস লাইভ কনটেস্ট ১');
      expect(fakeClient.lastGetPath, Endpoints.latestContest);
    });

    test('getAllContests queries Endpoints.allContestList and parses model', () async {
      fakeClient.getResponseData = {
        'status': true,
        'contests': [
          {'id': 1, 'title': 'কনটেস্ট ১'},
          {'id': 2, 'title': 'কনটেস্ট ২'},
        ],
      };

      final result = await repository.getAllContests();
      expect(result, isNotNull);
      expect(result?.status, true);
      expect(result?.contests?.length, 2);
      expect(fakeClient.lastGetPath, Endpoints.allContestList);
    });

    test('getLatestContestResult queries Endpoints.latestContestResult', () async {
      fakeClient.getResponseData = {
        'status': true,
        'contest_results': [
          {
            'id': 101,
            'user': {
              'id': 1,
              'name': 'সাকিব হাসান',
              'user_id': '1001',
            },
          }
        ],
      };

      final result = await repository.getLatestContestResult();
      expect(result, isNotNull);
      expect(result?.status, true);
      expect(result?.contestResults?.length, 1);
      expect(fakeClient.lastGetPath, Endpoints.latestContestResult);
    });

    test('startContest posts to correct URL and returns ContestStartModel', () async {
      fakeClient.postResponseData = {
        'status': true,
        'contest': {
          'id': 42,
          'title': 'মেগা কনটেস্ট',
          'duration': 3600,
        },
        'questions': [
          {
            'id': 10,
            'title': 'বাংলাদেশের জাতীয় কবি কে?',
          }
        ],
      };

      final result = await repository.startContest(42);
      expect(result, isNotNull);
      expect(result?.status, true);
      expect(result?.contest?.id, 42);
      expect(result?.questions?.length, 1);
      expect(fakeClient.lastPostPath, '${Endpoints.startContest}42/start');
    });

    test('submitContest posts user answers and parses ContestSubmitModel', () async {
      fakeClient.postResponseData = {
        'status': true,
        'message': 'কনটেস্ট সফলভাবে জমা দেওয়া হয়েছে',
        'summary': {
          'total': 1,
          'correct': 1,
          'incorrect': 0,
          'mark': 1.0,
        },
      };

      final result = await repository.submitContest(
        contestId: 42,
        userAnswers: [
          {'question_id': 10, 'answer': 1}
        ],
      );

      expect(result, isNotNull);
      expect(result?.status, true);
      expect(result?.summary?.correct, 1);
      expect(result?.summary?.mark, 1.0);
      expect(fakeClient.lastPostPath, '${Endpoints.startContest}42/submit');
      expect(fakeClient.lastPostData, {
        'user_answers': [
          {'question_id': 10, 'answer': 1}
        ]
      });
    });
  });

  group('LatestContestNotifier with Injected Repository', () {
    test('fetches latest contest and all contests properly', () async {
      final mockRepo = _MockContestRepository();
      mockRepo.latestContestToReturn = LatestContestModel(
        status: true,
        contest: Contest(id: 1, name: 'সাপ্তাহিক কনটেস্ট'),
      );
      mockRepo.allContestsToReturn = AllContestModel(
        status: true,
        contests: [shared.Contest(id: 1, name: 'সাপ্তাহিক কনটেস্ট')],
      );
      mockRepo.latestResultToReturn = ContestResultModel(
        status: true,
        contestResults: [],
      );

      final container = ProviderContainer(
        overrides: [
          latestContestNotifierProvider.overrideWith(
            () => LatestContestNotifier(repository: mockRepo),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(latestContestNotifierProvider.notifier);
      await notifier.fetchContest();
      await notifier.fetchAllContest();
      await notifier.fetchContestResult();

      final state = container.read(latestContestNotifierProvider);
      expect(state.contestModel?.contest?.name, 'সাপ্তাহিক কনটেস্ট');
      expect(state.allContestModel?.contests?.length, 1);
      expect(state.isLoading, false);
      expect(state.isResultLoading, false);
    });
  });

  group('ContestExamNotifier with Injected Repository', () {
    test('selectAnswer updates answers and submitContest calls repository', () async {
      final mockRepo = _MockContestRepository();
      mockRepo.submitContestToReturn = ContestSubmitModel(
        status: true,
        message: 'Submitted successfully',
      );

      final examModel = ContestStartModel(
        status: true,
        contest: shared.Contest(id: 99, duration: 300),
        questions: [
          Question(id: 1, title: 'প্রশ্ন ১'),
          Question(id: 2, title: 'প্রশ্ন ২'),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          contestExamNotifierProvider(examModel).overrideWith(
            () => ContestExamNotifier(examModel, repository: mockRepo),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(contestExamNotifierProvider(examModel).notifier);

      // Select an answer
      notifier.selectAnswer(1, 0);

      final stateAfterSelect =
          container.read(contestExamNotifierProvider(examModel));
      expect(stateAfterSelect.selectedAnswers[1], 0);
      expect(stateAfterSelect.userAnswers[0]?.answers, [0]);

      // Submit exam
      await notifier.finalSubmitExam();

      final stateAfterSubmit =
          container.read(contestExamNotifierProvider(examModel));
      expect(stateAfterSubmit.isExamSubmitted, true);
      expect(stateAfterSubmit.isLoading, false);
    });
  });
}
