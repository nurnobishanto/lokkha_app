import 'package:lokkha/features/contest/data/models/all_contest_model.dart';
import 'package:lokkha/features/contest/data/models/contest_result_model.dart';
import 'package:lokkha/features/contest/data/models/contest_start_model.dart';
import 'package:lokkha/features/contest/data/models/contest_submit_model.dart';
import 'package:lokkha/features/contest/data/models/latest_contest_model.dart';

abstract class ContestRepository {
  Future<LatestContestModel?> getLatestContest();

  Future<AllContestModel?> getAllContests();

  Future<ContestResultModel?> getLatestContestResult();

  Future<ContestStartModel?> startContest(int contestId);

  Future<ContestSubmitModel?> submitContest({
    required int contestId,
    required List<Map<String, dynamic>> userAnswers,
  });
}
