import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/features/course/course.dart';

class LectureSheetListController extends GetxController {
  final apiCallStatus = ApiCallStatus.holding.obs;
  final categories = <Category>[].obs;
  final isLoading = false.obs;
  final isLastPage = false.obs;
  final currentPage = 1.obs;

  Future<void> fetchSheetListCategories() async {
    if (isLoading.value || isLastPage.value) return;
    isLoading.value = true;
    print("Call Current After Page ${currentPage.value}");
    final url =
        "${AppConstants.lectureSheetCategories}?page=${currentPage.value}";
    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status']) {
          final model = LectureSheetListCategoriesModel.fromJson(response.data);
          if (model.categories?.data?.isNotEmpty ?? false) {
            categories.addAll(model.categories!.data!);
            currentPage.value++;
            isLastPage.value =
                model.categories!.currentPage == model.categories!.lastPage;
          } else {
            isLastPage.value = true;
          }
          apiCallStatus.value = ApiCallStatus.success;
        } else {
          apiCallStatus.value = ApiCallStatus.error;
        }
      },
      onLoading: () {
        if (categories.isEmpty) apiCallStatus.value = ApiCallStatus.loading;
      },
      onError: (error) {
        apiCallStatus.value = ApiCallStatus.error;
        debugPrint("Pagination Error: $error");
      },
    );

    isLoading.value = false;
  }

  @override
  void onInit() {
    fetchSheetListCategories();
    super.onInit();
  }
}
