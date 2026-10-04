import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/profile/data/models/order_v1_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_user_orders_usecase.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class MyOrdersController extends GetxController {
  final GetUserOrdersUseCase getUserOrdersUseCase;

  MyOrdersController({GetUserOrdersUseCase? getUserOrdersUseCase})
      : getUserOrdersUseCase = getUserOrdersUseCase ?? GetUserOrdersUseCase();

  // Observable state
  final RxList<OrderV1Item> orders = <OrderV1Item>[].obs;
  final Rx<OrderV1FilterCounts> filterCounts = OrderV1FilterCounts().obs;
  final Rx<ApiCallStatus> apiCallStatus = ApiCallStatus.holding.obs;

  // Filters
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedModelType = 'all'.obs;
  final RxString selectedPaymentMethod = 'all'.obs;

  // Search & Pagination
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final ScrollController scrollController = ScrollController();
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isRefreshing = false.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    fetchOrders(refresh: true);
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          hasMore.value &&
          !isLoadingMore.value &&
          apiCallStatus.value == ApiCallStatus.success) {
        loadMore();
      }
    });
  }

  /// Primary fetch method
  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = false;
      if (orders.isEmpty) {
        apiCallStatus.value = ApiCallStatus.loading;
      } else {
        isRefreshing.value = true;
      }
    }

    try {
      final response = await getUserOrdersUseCase(
        status: selectedStatus.value,
        modelType: selectedModelType.value,
        paymentMethod: selectedPaymentMethod.value,
        search: searchQuery.value.trim().isNotEmpty ? searchQuery.value.trim() : null,
        page: currentPage.value,
        perPage: 10,
      );

      filterCounts.value = response.filterCounts;
      hasMore.value = response.meta.hasMore;

      if (refresh) {
        orders.assignAll(response.items);
      } else {
        orders.addAll(response.items);
      }

      apiCallStatus.value = ApiCallStatus.success;
    } catch (e) {
      debugPrint('[MyOrdersController] fetchOrders error: $e');
      if (orders.isEmpty) {
        apiCallStatus.value = ApiCallStatus.error;
      } else {
        CustomSnackBar.showCustomErrorToast(message: "অর্ডার লোড করতে সমস্যা হয়েছে");
      }
    } finally {
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Backward compatibility alias
  Future<void> fetchMyOrders({required bool refresh}) async {
    await fetchOrders(refresh: refresh);
  }

  /// Pagination next page loader
  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;

    isLoadingMore.value = true;
    currentPage.value++;
    await fetchOrders(refresh: false);
  }

  /// Update status filter (e.g. 'all', 'paid', 'pending', 'failed')
  void setStatusFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchOrders(refresh: true);
  }

  /// Update model type filter (e.g. 'all', 'Package', 'Course', 'Exam')
  void setModelTypeFilter(String modelType) {
    if (selectedModelType.value == modelType) return;
    selectedModelType.value = modelType;
    fetchOrders(refresh: true);
  }

  /// Update payment method filter (e.g. 'all', 'bkash', 'sslcommerz')
  void setPaymentMethodFilter(String method) {
    if (selectedPaymentMethod.value == method) return;
    selectedPaymentMethod.value = method;
    fetchOrders(refresh: true);
  }

  /// Live Search input handler with debounce
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchOrders(refresh: true);
    });
  }

  /// Clear active search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchOrders(refresh: true);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
