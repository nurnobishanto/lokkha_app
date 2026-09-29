import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/features/jobs/jobs.dart';

class JobsController extends GetxController {
  RxBool isLoading = true.obs;
  RxInt currentPage = 1.obs;
  RxBool isFavourite = false.obs;
  RxString search = RxString("");
  RxObjectMixin<Job> detailsModel = Job().obs;
  RxObjectMixin<JobListModel> model = JobListModel().obs;
  int? id;

  Future<void> fetchJobs(String search,
      {int page = 1, bool refresh = false}) async {
    if (refresh) {
      MyGetStorage.removeCache(MyGetStorage.jobKey);
    }
    if (!refresh && MyGetStorage.getStorage.hasData(MyGetStorage.jobKey)) {
      var cacheData = MyGetStorage.readCache(MyGetStorage.jobKey);
      if (cacheData != null) {
        model.value = JobListModel.fromJson(cacheData);
        isLoading.value = false;
      }
    }
    isLoading.value = true;
    String url = "${AppConstants.jobsList}?search=$search&page=$page";

    BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data["status"]) {
          JobListModel modelData = JobListModel.fromJson(response.data);
          MyGetStorage.writeCacheData(MyGetStorage.jobKey, response.data);
          if (page > 1 && model.value.jobs != null) {
            // Merge new data with existing data
            model.value.jobs!.data!.addAll(modelData.jobs!.data!);
          } else {
            model.value = modelData;
          }
          currentPage.value = page;
          isLoading.value = false;
        } else {
          isLoading.value = false;
          if (kDebugMode) {
            print("ERROR ::::::: ");
          }
        }
      },
    );
  }

  // Get jobs list from api method
  Future<void> getSingleJob(int id) async {
    isLoading.value = true;
    String url = "${AppConstants.job}/$id";
    BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data["status"]) {
          if (kDebugMode) {
            print("GobJobs Model Data $response");
          }
          Job modelData = Job.fromJson(response.data['job']);
          detailsModel.value = modelData;
          //isFavourite.value = model.value.isSaved!;
          isLoading.value = false;
        } else {
          isLoading.value = false;
          if (kDebugMode) {
            print("ERROR ::::::: ");
          }
        }
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.currentRoute == Routes.JOB_DETAILS) {
      print("Called... Get.currentRoute == Routes.JOB_DETAILS");
      final args = Get.arguments as int;
      id = args;
    }
    fetchJobs("");
  }
}

String getFullUrl(String? path) {
  if (path == null || path.isEmpty) return "";

  if (path.startsWith("http")) {
    return path;
  }

  return "${AppConstants.storageUrl}$path";
}
