import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/features/course/course.dart';

class LectureSheetListDetailsController extends GetxController {
  final apiCallStatus = ApiCallStatus.holding.obs;
  final lectureSheets = <Category>[].obs;
  final isLoading = false.obs;
  final isLastPage = false.obs;
  final currentPage = 1.obs;
  final detailsModel = Rxn<LectureSheetCategory>();

  int? categoryId;

  @override
  void onInit() {
    super.onInit();
    if (categoryId != null) {
      fetchSheetListCategories(categoryId!);
    }
  }

  void setCategoryId(int id) {
    categoryId = id;
    fetchSheetListCategories(id);
  }

  Future<void> fetchSheetListCategories(int id) async {
    if (isLoading.value || isLastPage.value) return;

    isLoading.value = true;
    final url =
        "${AppConstants.lectureSheetCategories}/$id?page=${currentPage.value}";

    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        final data = response.data;
        if (data['status'] == true) {
          final model = LectureSheetCategory.fromJson(data);
          detailsModel.value = model;

          final sheets = model.lecturesheets?.data ?? [];
          if (sheets.isNotEmpty) {
            lectureSheets.addAll(sheets);
            currentPage.value++;
            isLastPage.value = model.lecturesheets!.currentPage ==
                model.lecturesheets!.lastPage;
          } else {
            isLastPage.value = true;
          }

          apiCallStatus.value = ApiCallStatus.success;
        } else {
          apiCallStatus.value = ApiCallStatus.error;
        }
      },
      onLoading: () {
        if (lectureSheets.isEmpty) {
          apiCallStatus.value = ApiCallStatus.loading;
        }
      },
      onError: (error) {
        apiCallStatus.value = ApiCallStatus.error;
        debugPrint("Error: $error");
      },
    );

    isLoading.value = false;
  }
}
