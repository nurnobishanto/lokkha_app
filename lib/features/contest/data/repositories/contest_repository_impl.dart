import 'package:lokkha/features/contest/data/datasources/contest_remote_data_source.dart';
import 'package:lokkha/features/contest/data/models/all_contest_model.dart';
import 'package:lokkha/features/contest/data/models/contest_result_model.dart';
import 'package:lokkha/features/contest/data/models/contest_start_model.dart';
import 'package:lokkha/features/contest/data/models/contest_submit_model.dart';
import 'package:lokkha/features/contest/data/models/latest_contest_model.dart';
import 'package:lokkha/features/contest/domain/repositories/contest_repository.dart';

class ContestRepositoryImpl implements ContestRepository {
  final ContestRemoteDataSource remoteDataSource;

  ContestRepositoryImpl({ContestRemoteDataSource? remoteDataSource})
      : remoteDataSource =
            remoteDataSource ?? ContestRemoteDataSourceImpl();

  @override
  Future<LatestContestModel?> getLatestContest() {
    return remoteDataSource.getLatestContest();
  }

  @override
  Future<AllContestModel?> getAllContests() {
    return remoteDataSource.getAllContests();
  }

  @override
  Future<ContestResultModel?> getLatestContestResult() {
    return remoteDataSource.getLatestContestResult();
  }

  @override
  Future<ContestStartModel?> startContest(int contestId) {
    return remoteDataSource.startContest(contestId);
  }

  @override
  Future<ContestSubmitModel?> submitContest({
    required int contestId,
    required List<Map<String, dynamic>> userAnswers,
  }) {
    return remoteDataSource.submitContest(
      contestId: contestId,
      userAnswers: userAnswers,
    );
  }
}
