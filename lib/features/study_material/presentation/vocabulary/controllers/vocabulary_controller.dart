import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/study_material/study_material.dart';

import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/shared/models/vocabulary.dart';
import 'package:lokkha/core/network/api_call_status.dart';

class VocabularyController extends GetxController {
  RxBool isLoading = true.obs;
  RxString search = RxString("");
  var selectedAlphabet = ''.obs;

  // TextEditingController
  final searchTextController = TextEditingController().obs;

  // filtered list for real-time search
  RxList<Vocabulary> filteredVocab = <Vocabulary>[].obs;

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  final isLastPage = false.obs;

  final apiCallStatus = ApiCallStatus.holding.obs;
  final Rxn<Category> selectedType = Rxn<Category>();
  final Rxn<Category> selectedCategory = Rxn<Category>();

  Rx<VocabularyModel> model = VocabularyModel().obs;

  void setType(Category type) => selectedType.value = type;
  void setCategory(Category category) => selectedCategory.value = category;

  Future<void> fetchVocabulary({bool refresh = false}) async {
    isLoading.value = true;
    String url = AppConstants.vocabularies;

    Map<String, dynamic> data = {
      'alphabet': selectedAlphabet.value.toUpperCase(),
      'page': currentPage.value,
      'search': search.value.toString(),
    };
    if (selectedType.value?.id != null) {
      data['type_ids[]'] = [selectedType.value!.id!];
    }
    if (selectedCategory.value?.id != null) {
      data['category_ids[]'] = [selectedCategory.value!.id!];
    }

    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      queryParameters: data,
      onSuccess: (response) {
        if (response.data["status"]) {
          VocabularyModel modelData = VocabularyModel.fromJson(response.data);
          selectedAlphabet.value =
              modelData.selectedAlphabet?.toUpperCase() ?? '';
          model.value = modelData;
          totalPages.value = modelData.vocabularies?.lastPage ?? 1;
          isLastPage.value = modelData.vocabularies?.currentPage ==
              modelData.vocabularies?.lastPage;

          // Initialize filteredVocab
          filteredVocab.value = modelData.vocabularies?.data ?? [];

          apiCallStatus.value = ApiCallStatus.success;
        } else {
          apiCallStatus.value = ApiCallStatus.error;
          filteredVocab.clear();
        }
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint("API Error: $error");
        isLoading.value = false;
      },
    );
  }

  // Pagination helpers
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchVocabulary();
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchVocabulary();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchVocabulary();
    }
  }

  void firstPage() => goToPage(1);
  void lastPage() => goToPage(totalPages.value);

  @override
  void onInit() {
    super.onInit();
    fetchVocabulary();

    // Real-time local search with debounce
    debounce(search, (_) {
      if (search.value.isEmpty) {
        filteredVocab.value = model.value.vocabularies?.data ?? [];
      } else {
        filteredVocab.value = model.value.vocabularies?.data
                ?.where((v) =>
                    v.word!.toLowerCase().contains(search.value.toLowerCase()))
                .toList() ??
            [];
      }
    }, time: const Duration(milliseconds: 200));
  }

  @override
  void onClose() {
    searchTextController.value.dispose();
    super.onClose();
  }
}
