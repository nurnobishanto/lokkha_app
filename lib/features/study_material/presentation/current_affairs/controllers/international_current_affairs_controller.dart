import 'package:get/get.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/core/core.dart';

class InternationalCurrentAffairsController extends GetxController {
  RxBool isLoading = true.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxString search = RxString("");

  RxObjectMixin<CurrentAffairsModel> model = CurrentAffairsModel().obs;

  Future<void> fetchCurrentAffairs(String search,
      {int page = 1, bool refresh = false, String? date}) async {
    isLoading.value = true;
    final dateParam = (date != null && date.isNotEmpty) ? '&date=$date' : '';
    String url =
        "${AppConstants.internationalCA}?search=$search&page=$page$dateParam";

    BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data["status"]) {
          model.value = CurrentAffairsModel.fromJson(response.data);
          currentPage.value = page;
          totalPages.value = model.value.currentAffairs?.lastPage ?? 1;
        }
        isLoading.value = false;
      },
      onError: (err) {
        isLoading.value = false;
      },
    );
  }

  // ---------- Pagination Actions ----------
  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    fetchCurrentAffairs("", page: page);
  }

  @override
  void onInit() {
    super.onInit();
    fetchCurrentAffairs("");
  }
}
