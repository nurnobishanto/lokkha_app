import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

// ============================================================================
// 1. Models & Helper Classes
// ============================================================================

class RankCardUser {
  final int sl;
  final int rank;
  final String userId;
  final int resultId;
  final String? image;
  final User user;

  RankCardUser({
    required this.sl,
    required this.rank,
    required this.userId,
    required this.resultId,
    this.image,
    required this.user,
  });
}

class ContestTimerState {
  final int hours;
  final int minutes;
  final int seconds;
  final String status; // 'timer', 'ongoing', 'ended'

  const ContestTimerState({
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.status = 'timer',
  });
}

// ============================================================================
// 2. Latest Contest Notifier & State
// ============================================================================

class LatestContestState {
  final bool isLoading;
  final bool isResultLoading;
  final ApiCallStatus apiCallStatus;
  final LatestContestModel? contestModel;
  final AllContestModel? allContestModel;
  final ContestResultModel? lastContestResultModel;
  final List<RankCardUser> rankUsers;
  final String imageUrl;
  final int hours;
  final int minutes;
  final int seconds;
  final String status; // 'timer', 'ongoing', 'ended'
  final Map<int, ContestTimerState> contestTimers;

  LatestContestState({
    this.isLoading = true,
    this.isResultLoading = true,
    this.apiCallStatus = ApiCallStatus.holding,
    this.contestModel,
    this.allContestModel,
    this.lastContestResultModel,
    this.rankUsers = const [],
    this.imageUrl =
        "https://media.4-paws.org/f/8/0/5/f8055215b5cdc5dee5494c255ca891d7b7d33cd1/Molly_006-2829x1886-2726x1886.jpg",
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.status = 'timer',
    this.contestTimers = const {},
  });

  LatestContestState copyWith({
    bool? isLoading,
    bool? isResultLoading,
    ApiCallStatus? apiCallStatus,
    LatestContestModel? contestModel,
    AllContestModel? allContestModel,
    ContestResultModel? lastContestResultModel,
    List<RankCardUser>? rankUsers,
    String? imageUrl,
    int? hours,
    int? minutes,
    int? seconds,
    String? status,
    Map<int, ContestTimerState>? contestTimers,
  }) {
    return LatestContestState(
      isLoading: isLoading ?? this.isLoading,
      isResultLoading: isResultLoading ?? this.isResultLoading,
      apiCallStatus: apiCallStatus ?? this.apiCallStatus,
      contestModel: contestModel ?? this.contestModel,
      allContestModel: allContestModel ?? this.allContestModel,
      lastContestResultModel:
          lastContestResultModel ?? this.lastContestResultModel,
      rankUsers: rankUsers ?? this.rankUsers,
      imageUrl: imageUrl ?? this.imageUrl,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      status: status ?? this.status,
      contestTimers: contestTimers ?? this.contestTimers,
    );
  }
}

class LatestContestNotifier extends Notifier<LatestContestState> {
  Timer? _tickerTimer;
  final RestClient _client;

  LatestContestNotifier({RestClient? client})
      : _client = client ?? RestClient();

  @override
  LatestContestState build() {
    ref.onDispose(() {
      _tickerTimer?.cancel();
    });

    Future.microtask(() {
      fetchContest();
      fetchContestResult();
      fetchAllContest();
    });

    _startGlobalTicker();
    return LatestContestState();
  }

  void _startGlobalTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateAllTimers();
    });
  }

  void _updateAllTimers() {
    final now = DateTime.now();

    // 1. Update latest contest timer
    int h = state.hours;
    int m = state.minutes;
    int s = state.seconds;
    String currentStatus = state.status;

    final latestContest = state.contestModel?.contest;
    if (latestContest != null &&
        latestContest.startDatetime != null &&
        latestContest.endDatetime != null) {
      try {
        final startDt = DateTime.parse(latestContest.startDatetime.toString());
        final endDt = DateTime.parse(latestContest.endDatetime.toString());

        if (startDt.isAfter(now)) {
          int diffSec = startDt.difference(now).inSeconds;
          if (diffSec > 0) {
            h = diffSec ~/ 3600;
            m = (diffSec % 3600) ~/ 60;
            s = diffSec % 60;
            currentStatus = 'timer';
          } else {
            currentStatus = 'ongoing';
          }
        } else if (now.isBefore(endDt)) {
          currentStatus = 'ongoing';
        } else {
          currentStatus = 'ended';
        }
      } catch (_) {}
    }

    // 2. Update all contest timers
    final Map<int, ContestTimerState> updatedTimers = {};
    final contests = state.allContestModel?.contests ?? [];
    for (final contest in contests) {
      final id = contest.id;
      if (id == null) continue;

      if (contest.startDatetime != null && contest.endDatetime != null) {
        try {
          final start = DateTime.parse(contest.startDatetime.toString());
          final end = DateTime.parse(contest.endDatetime.toString());

          if (start.isAfter(now)) {
            int diff = start.difference(now).inSeconds;
            if (diff > 0) {
              updatedTimers[id] = ContestTimerState(
                hours: diff ~/ 3600,
                minutes: (diff % 3600) ~/ 60,
                seconds: diff % 60,
                status: 'timer',
              );
            } else {
              updatedTimers[id] = const ContestTimerState(status: 'ongoing');
            }
          } else if (now.isBefore(end)) {
            updatedTimers[id] = const ContestTimerState(status: 'ongoing');
          } else {
            updatedTimers[id] = const ContestTimerState(status: 'ended');
          }
        } catch (_) {}
      }
    }

    state = state.copyWith(
      hours: h,
      minutes: m,
      seconds: s,
      status: currentStatus,
      contestTimers: updatedTimers,
    );
  }

  Future<void> fetchContest() async {
    state = state.copyWith(isLoading: true);
    final url = AppConstants.latestContest;
    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        final model = LatestContestModel.fromJson(response.data);
        final img = model.contest?.image != null
            ? '${AppConstants.storageUrl}${model.contest!.image}'
            : state.imageUrl;
        state = state.copyWith(
          isLoading: false,
          contestModel: model,
          imageUrl: img,
        );
        _updateAllTimers();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchAllContest() async {
    state = state.copyWith(isLoading: true);
    final url = AppConstants.allContestList;
    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        final model = AllContestModel.fromJson(response.data);
        state = state.copyWith(
          isLoading: false,
          allContestModel: model,
        );
        _updateAllTimers();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchContestResult() async {
    state = state.copyWith(isResultLoading: true);
    final url = AppConstants.latestContestResult;
    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        final model = ContestResultModel.fromJson(response.data);
        final results = model.contestResults ?? [];
        final List<RankCardUser> list = [];

        for (int i = 0; i < results.length; i++) {
          final result = results[i];
          if (result.user == null) continue;
          final sl = i == 0
              ? 1
              : i == 1
                  ? 0
                  : i;
          final userImg = AppConstants.resolveUrl(
              result.user!.image ?? result.user!.avatar);
          list.add(
            RankCardUser(
              userId: result.user!.userId?.toString() ?? '',
              rank: i + 1,
              image: userImg.isNotEmpty
                  ? userImg
                  : 'https://lokkha.com/uploads/files/shares/app/avatar.png',
              sl: sl,
              resultId: result.id?.toInt() ?? 0,
              user: result.user!,
            ),
          );
        }
        list.sort((a, b) => a.sl.compareTo(b.sl));

        state = state.copyWith(
          isResultLoading: false,
          lastContestResultModel: model,
          rankUsers: list,
        );
      } else {
        state = state.copyWith(isResultLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isResultLoading: false);
    }
  }

  Future<void> startContest(BuildContext context, int id) async {
    final token = MySharedPref.getUserToken();
    if (token.isEmpty) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AuthGatewayView()),
        );
      }
      return;
    }

    try {
      final response = await _client.post(
        '${AppConstants.startContest}$id/start',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.data['status'] == true) {
        final data = ContestStartModel.fromJson(response.data);
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContestExamView(examStartModel: data),
            ),
          );
        }
      } else if (response.data['status'] == false) {
        if (response.data['package_required'] == true) {
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PremiumPackagesView(),
              ),
            );
          }
        }
        CustomSnackBar.showCustomErrorToast(
          message: response.data['message']?.toString() ?? '',
        );
      }
    } catch (_) {}
  }
}

final latestContestNotifierProvider =
    NotifierProvider<LatestContestNotifier, LatestContestState>(
  LatestContestNotifier.new,
);

// ============================================================================
// 3. Contest Exam Notifier & State
// ============================================================================

class ContestExamState {
  final ContestStartModel exam;
  final int durationSeconds;
  final bool isLoading;
  final bool isExamSubmitted;
  final Map<int, dynamic> selectedAnswers;
  final Map<int, UserAnswer> userAnswers;

  ContestExamState({
    required this.exam,
    this.durationSeconds = 0,
    this.isLoading = false,
    this.isExamSubmitted = false,
    this.selectedAnswers = const {},
    this.userAnswers = const {},
  });

  ContestExamState copyWith({
    int? durationSeconds,
    bool? isLoading,
    bool? isExamSubmitted,
    Map<int, dynamic>? selectedAnswers,
    Map<int, UserAnswer>? userAnswers,
  }) {
    return ContestExamState(
      exam: exam,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isLoading: isLoading ?? this.isLoading,
      isExamSubmitted: isExamSubmitted ?? this.isExamSubmitted,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      userAnswers: userAnswers ?? this.userAnswers,
    );
  }
}

class ContestExamNotifier extends Notifier<ContestExamState> {
  final ContestStartModel exam;
  final RestClient _client;
  Timer? _timer;

  ContestExamNotifier(this.exam, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  ContestExamState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final dur = exam.contest?.duration ?? 0;
    final initialMap = _initUserAnswers({});

    Future.microtask(() {
      _startTimer();
    });

    return ContestExamState(
      exam: exam,
      durationSeconds: dur,
      userAnswers: initialMap,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.durationSeconds > 0) {
        state = state.copyWith(durationSeconds: state.durationSeconds - 1);
      } else {
        timer.cancel();
        // Time over, auto submit
        finalSubmitExam();
      }
    });
  }

  Map<int, UserAnswer> _initUserAnswers(Map<int, dynamic> selected) {
    final Map<int, UserAnswer> map = {};
    final questions = exam.questions ?? [];
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final ans = selected[q.id];
      final answerAsList = (ans != null)
          ? (ans is List ? ans : [ans])
          : null;
      map[i] = UserAnswer(
        questionId: q.id?.toInt() ?? 0,
        answers: answerAsList,
      );
    }
    return map;
  }

  void selectAnswer(int questionId, dynamic answer) {
    if (state.selectedAnswers[questionId] == null) {
      final updated = Map<int, dynamic>.from(state.selectedAnswers);
      updated[questionId] = answer;
      final updatedUserAnswers = _initUserAnswers(updated);
      state = state.copyWith(
        selectedAnswers: updated,
        userAnswers: updatedUserAnswers,
      );
    }
  }

  Future<void> finalSubmitExam({BuildContext? context}) async {
    if (state.isExamSubmitted) return;
    state = state.copyWith(isLoading: true, isExamSubmitted: true);

    final token = MySharedPref.getUserToken();
    final headers = {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final url = '${AppConstants.startContest}${exam.contest?.id}/submit';

    final userAnswersArray =
        state.userAnswers.values.map((u) => u.toJson()).toList();
    final data = {
      'user_answers': userAnswersArray,
    };

    try {
      final response = await _client.post(
        url,
        headers: headers,
        data: data,
      );
      if (response.data['status'] == true) {
        await MySharedPref.clearMockSubjects();
        final modelData = ContestSubmitModel.fromJson(response.data);
        state = state.copyWith(isLoading: false);
        if (context != null && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ContestSubmitView(model: modelData),
            ),
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final contestExamNotifierProvider =
    NotifierProvider.family<ContestExamNotifier, ContestExamState, ContestStartModel>(
  ContestExamNotifier.new,
);
