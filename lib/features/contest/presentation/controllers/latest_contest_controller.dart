import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/contest/presentation/views/contest_exam_view.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/core/constants/app_constants.dart';

import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/core/network/api_call_status.dart';

class LatestContestController extends GetxController {
  Rx<ApiCallStatus> apiCallStatus = ApiCallStatus.holding.obs;
  /// start Timer
  Timer? _timer;
  RxInt hours = 0.obs;
  RxInt minutes = 0.obs;
  RxInt seconds = 0.obs;
  RxString status = 'timer'.obs;
  RxString imageUrl =
      "https://media.4-paws.org/f/8/0/5/f8055215b5cdc5dee5494c255ca891d7b7d33cd1/Molly_006-2829x1886-2726x1886.jpg"
          .obs;
  RxList rankUsers = [].obs;

  void startTimer({required int hours}) {
    this.hours.value = hours;
    minutes.value = 0;
    seconds.value = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else if (minutes.value > 0) {
        minutes.value--;
        seconds.value = 59;
      } else if (this.hours.value > 0) {
        this.hours.value--;
        minutes.value = 59;
        seconds.value = 59;
      } else {
        timer.cancel();
      }
      update();
      debugPrint("Called Timer.....${timer.tick} xx");
    });
  }

  void checkAndStartTimer(
      {required DateTime startDatetime, required DateTime endDatetime}) {
    final now = DateTime.now();

    if (startDatetime.isAfter(now)) {
      // 🟢 Future: Start countdown until the event starts
      int totalSeconds = startDatetime.difference(now).inSeconds;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (totalSeconds > 0) {
          totalSeconds--;

          hours.value = totalSeconds ~/ 3600;
          minutes.value = (totalSeconds % 3600) ~/ 60;
          seconds.value = totalSeconds % 60;
        } else {
          status.value = 'ongoing';
          timer.cancel();
          if (kDebugMode) {
            print("✅ Event Started. You can now show Ongoing or do something.");
          }
          // এখানে চাইলে নতুন আরেকটা Timer চালিয়ে ongoing এর সময় ট্র্যাক করতে পারো
        }
        update();
      });
    } else if (now.isBefore(endDatetime)) {
      // 🟡 Event ongoing
      status.value = 'ongoing';
    } else {
      status.value = 'ended';
      // 🔴 Event ended
    }
  }

  String checkStatus(
      {required DateTime startDatetime, required DateTime endDatetime}) {
    final now = DateTime.now();

    if (startDatetime.isAfter(now)) {
      // 🟢 Future: Start countdown until the event starts
      int totalSeconds = startDatetime.difference(now).inSeconds;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (totalSeconds > 0) {
          totalSeconds--;

          hours.value = totalSeconds ~/ 3600;
          minutes.value = (totalSeconds % 3600) ~/ 60;
          seconds.value = totalSeconds % 60;
        } else {
          status.value = 'ongoing';
          timer.cancel();
          if (kDebugMode) {
            print("✅ Event Started. You can now show Ongoing or do something.");
          }
        }
        update();
      });
    } else if (now.isBefore(endDatetime)) {
      // 🟡 Event ongoing
      status.value = 'ongoing';
    } else {
      status.value = 'ended';
      // 🔴 Event ended
    }
    return status.value;
  }

  final List<int> leaders = List.generate(30, (index) {
    return index + 1;
  });
  RxObjectMixin<LatestContestModel> contestModel = LatestContestModel().obs;
  final isLoading = true.obs;

  /// Fetch Contest Method
  Future<void> fetchContest() async {
    isLoading.value = true;
    var url = AppConstants.latestContest;
    BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status']) {
          contestModel.value = LatestContestModel.fromJson(response.data);
          imageUrl.value = AppConstants.storageUrl +
              contestModel.value.contest!.image.toString();
          checkAndStartTimer(
              startDatetime: DateTime.parse(
                  contestModel.value.contest!.startDatetime.toString()),
              endDatetime: DateTime.parse(
                  contestModel.value.contest!.endDatetime.toString()));
        } else {
          debugPrint('err');
        }
        isLoading.value = false;
      },
    );
  }

  /// Fetch All Contest List Method
  /// All contest timer tracking
  final contestTimers = <int, ContestTimerModel>{}.obs;
  RxObjectMixin<AllContestModel> allContestModel = AllContestModel().obs;

  Future<void> fetchAllContest() async {
    isLoading.value = true;
    var url = AppConstants.allContestList;

    BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status']) {
          allContestModel.value = AllContestModel.fromJson(response.data);

          for (var contest in allContestModel.value.contests!) {
            final id = contest.id!;
            if (!contestTimers.containsKey(id)) {
              final timerModel = ContestTimerModel();
              timerModel.start(
                DateTime.parse(contest.startDatetime!.toString()),
                DateTime.parse(contest.endDatetime!.toString()),
              );
              contestTimers[id] = timerModel;
            }
          }
        } else {
          debugPrint('error');
        }
        isLoading.value = false;
      },
    );
  }

  RxObjectMixin<ContestResultModel> lastContestResultModel =
      ContestResultModel().obs;
  final isResultLoading = true.obs;

  /// Fetch Contest Result Method
  Future<void> fetchContestResult() async {
    isLoading.value = true;
    rankUsers.clear();
    var url = AppConstants.latestContestResult;
    BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status']) {
          lastContestResultModel.value =
              ContestResultModel.fromJson(response.data);

          for (int i = 0;
              i < lastContestResultModel.value.contestResults!.length;
              i++) {
            var result = lastContestResultModel.value.contestResults![i];
            int sl = i == 0
                ? 1
                : i == 1
                    ? 0
                    : i;
            rankUsers.add(
              RankCardUser(
                  userId: result.user!.userId.toString(),
                  rank: i + 1,
                  image: (result.user!.image != null &&
                          result.user!.image != '')
                      ? AppConstants.storageUrl + result.user!.image.toString()
                      : (result.user!.avatar != null &&
                              result.user!.avatar != '')
                          ? result.user!.avatar
                          : 'https://lokkha.com/uploads/files/shares/app/avatar.png',
                  sl: sl,
                  resultId: result.id!.toInt(),
                  user: result.user!),
            );
          }

          isResultLoading.value = false;
          rankUsers.sort((a, b) => a.sl.compareTo(b.sl));
        } else {
          debugPrint('err');
          isResultLoading.value = false;
        }
        isLoading.value = false;
      },
    );
  }

  Rx<ContestStartModel> contestStartModel = ContestStartModel().obs;

  /// Fetch Contest Start Method
  Future<void> startContest(int id) async {
    String? token = MySharedPref.getUserToken();
    if (token == '' || token.isEmpty) return Get.to(const AuthGatewayView());
    await BaseClient.safeApiCall(
      '${AppConstants.startContest}$id/start',
      RequestType.post,
      headers: {
        "Authorization": 'Bearer $token',
      },
      onSuccess: (response) {
        apiCallStatus.value = ApiCallStatus.success;
        if (response.data['status']) {
          log("Called Success MOCK EXAM");
          isLoading.value = false;
          ContestStartModel data = ContestStartModel.fromJson(response.data);
          contestStartModel.value = data;
          Get.to(() => ContestExamView(
                examStartModel: contestStartModel.value,
              ));
        } else if (response.data["status"] == false) {
          if (response.data["package_required"] == true) {
            Get.to(() => const PremiumPackagesView());
          }
          CustomSnackBar.showCustomErrorToast(
              message: response.data["message"].toString());
        }
      },
    );
  }

  @override
  void onInit() {
    fetchContest();
    fetchContestResult();
    fetchAllContest();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    _timer?.cancel();
    for (var timer in contestTimers.values) {
      timer.dispose();
    }
  }
}

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

class ContestTimerModel {
  RxInt hours = 0.obs;
  RxInt minutes = 0.obs;
  RxInt seconds = 0.obs;
  RxString status = 'timer'.obs;
  Timer? timer;

  void start(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();

    if (startTime.isAfter(now)) {
      int totalSeconds = startTime.difference(now).inSeconds;

      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (totalSeconds > 0) {
          totalSeconds--;

          hours.value = totalSeconds ~/ 3600;
          minutes.value = (totalSeconds % 3600) ~/ 60;
          seconds.value = totalSeconds % 60;
        } else {
          status.value = 'ongoing';
          t.cancel();
        }
      });
    } else if (now.isBefore(endTime)) {
      status.value = 'ongoing';
    } else {
      status.value = 'ended';
    }
  }

  void dispose() {
    timer?.cancel();
  }
}
