import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/exam/exam.dart';

import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/network/base_client.dart';

class ExamCategoryDetailsController extends GetxController {
  int? categoryId;
  @override
  void onInit() {
    super.onInit();
    categoryId = _extractCategoryId();
    if (categoryId != null) {
      fetchExamCategoryDetails(categoryId!);
      fetchExamCategoriesWithParentID(categoryId!);
    }
  }

  int? _extractCategoryId() {
    if (Get.parameters.isNotEmpty) {
      final param = Get.parameters['category_id'] ?? Get.parameters['id'];
      if (param != null && param.isNotEmpty) {
        final parsed = int.tryParse(param);
        if (parsed != null) return parsed;
      }
    }
    final args = Get.arguments;
    if (args != null) {
      if (args is int) return args;
      if (args is String) return int.tryParse(args);
      if (args is Map) {
        final rawId = args['category_id'] ?? args['id'];
        if (rawId is int) return rawId;
        if (rawId != null) return int.tryParse(rawId.toString());
      }
    }
    return null;
  }

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  final isLastPage = false.obs;
  void firstPage() => goToPage(1);
  void lastPage() => goToPage(totalPages.value);

  // Pagination helpers
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value && categoryId != null) {
      currentPage.value = page;
      fetchExamCategoryDetails(categoryId!);
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value && categoryId != null) {
      currentPage.value++;
      fetchExamCategoryDetails(categoryId!);
    }
  }

  void previousPage() {
    if (currentPage.value > 1 && categoryId != null) {
      currentPage.value--;
      fetchExamCategoryDetails(categoryId!);
    }
  }

  final model = ExamCategoryDetailsModel().obs;
  final apiCallStatus = ApiCallStatus.holding.obs;

  Future<void> fetchExamCategoryDetails(int categoryId) async {
    apiCallStatus.value = ApiCallStatus.loading;
    try {
      final url =
          "${AppConstants.examsCategory}/$categoryId?page=${currentPage.value}";
      await BaseClient.safeApiCall(url, RequestType.get, onSuccess: (response) {
        if (response.data['status']) {
          model.value = ExamCategoryDetailsModel.fromJson(response.data);
          totalPages.value = model.value.freeExams?.lastPage ?? 1;
          isLastPage.value = model.value.freeExams?.currentPage ==
              model.value.freeExams?.lastPage;

          apiCallStatus.value = ApiCallStatus.success;
        } else {
          apiCallStatus.value = ApiCallStatus.error;
        }
      }, onError: (err) {
        apiCallStatus.value = ApiCallStatus.error;
        debugPrint("error from fetchExamCategoryDetails $err");
      });
    } catch (e) {
      apiCallStatus.value = ApiCallStatus.error;
    }
  }

  // With parent ID
  final examCategoriesModel = ExamCategoriesModel().obs;
  final apiCallCategoriesStatus = ApiCallStatus.holding.obs;
  Future<void> fetchExamCategoriesWithParentID(int parentID) async {
    apiCallCategoriesStatus.value = ApiCallStatus.loading;
    try {
      final url = "${AppConstants.examsCategories}?parent_id=$parentID";
      await BaseClient.safeApiCall(url, RequestType.get, onSuccess: (response) {
        if (response.data['status']) {
          examCategoriesModel.value =
              ExamCategoriesModel.fromJson(response.data);
          apiCallCategoriesStatus.value = ApiCallStatus.success;
        } else {
          apiCallCategoriesStatus.value = ApiCallStatus.error;
        }
      }, onError: (err) {
        apiCallCategoriesStatus.value = ApiCallStatus.error;
        debugPrint("error from fetchExamCategories $err");
      });
    } catch (e) {
      apiCallStatus.value = ApiCallStatus.error;
    }
  }
}
