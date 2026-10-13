import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/features/profile/data/models/order_v1_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_user_orders_usecase.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class MyOrdersState {
  final List<OrderV1Item> orders;
  final OrderV1FilterCounts filterCounts;
  final ApiCallStatus apiCallStatus;
  final String selectedStatus;
  final String selectedModelType;
  final String selectedPaymentMethod;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  MyOrdersState({
    this.orders = const [],
    OrderV1FilterCounts? filterCounts,
    this.apiCallStatus = ApiCallStatus.holding,
    this.selectedStatus = 'all',
    this.selectedModelType = 'all',
    this.selectedPaymentMethod = 'all',
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  }) : filterCounts = filterCounts ?? OrderV1FilterCounts();

  MyOrdersState copyWith({
    List<OrderV1Item>? orders,
    OrderV1FilterCounts? filterCounts,
    ApiCallStatus? apiCallStatus,
    String? selectedStatus,
    String? selectedModelType,
    String? selectedPaymentMethod,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return MyOrdersState(
      orders: orders ?? this.orders,
      filterCounts: filterCounts ?? this.filterCounts,
      apiCallStatus: apiCallStatus ?? this.apiCallStatus,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedModelType: selectedModelType ?? this.selectedModelType,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class MyOrdersNotifier extends Notifier<MyOrdersState> {
  final GetUserOrdersUseCase? _injectedUseCase;
  late final GetUserOrdersUseCase _getUserOrdersUseCase;

  MyOrdersNotifier({GetUserOrdersUseCase? getUserOrdersUseCase})
      : _injectedUseCase = getUserOrdersUseCase;

  @override
  MyOrdersState build() {
    _getUserOrdersUseCase = _injectedUseCase ?? GetUserOrdersUseCase();
    Future.microtask(() => fetchOrders(refresh: true));
    return MyOrdersState(apiCallStatus: ApiCallStatus.loading);
  }

  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        hasMore: false,
        apiCallStatus: state.orders.isEmpty ? ApiCallStatus.loading : state.apiCallStatus,
        isRefreshing: state.orders.isNotEmpty,
      );
    }

    try {
      final response = await _getUserOrdersUseCase(
        status: state.selectedStatus,
        modelType: state.selectedModelType,
        paymentMethod: state.selectedPaymentMethod,
        search: state.searchQuery.trim().isNotEmpty ? state.searchQuery.trim() : null,
        page: state.currentPage,
        perPage: 10,
      );

      final newOrders = refresh
          ? response.items
          : [...state.orders, ...response.items];

      state = state.copyWith(
        orders: newOrders,
        filterCounts: response.filterCounts,
        hasMore: response.meta.hasMore,
        apiCallStatus: ApiCallStatus.success,
        isRefreshing: false,
        isLoadingMore: false,
      );
    } catch (e) {
      debugPrint('[MyOrdersNotifier] fetchOrders error: $e');
      if (state.orders.isEmpty) {
        state = state.copyWith(
          apiCallStatus: ApiCallStatus.error,
          isRefreshing: false,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          isRefreshing: false,
          isLoadingMore: false,
        );
        CustomSnackBar.showCustomErrorToast(message: "অর্ডার লোড করতে সমস্যা হয়েছে");
      }
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(
      isLoadingMore: true,
      currentPage: state.currentPage + 1,
    );
    await fetchOrders(refresh: false);
  }

  void setStatusFilter(String status) {
    if (state.selectedStatus == status) return;
    state = state.copyWith(selectedStatus: status);
    fetchOrders(refresh: true);
  }

  void setModelTypeFilter(String modelType) {
    if (state.selectedModelType == modelType) return;
    state = state.copyWith(selectedModelType: modelType);
    fetchOrders(refresh: true);
  }

  void setPaymentMethodFilter(String method) {
    if (state.selectedPaymentMethod == method) return;
    state = state.copyWith(selectedPaymentMethod: method);
    fetchOrders(refresh: true);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchOrders(refresh: true);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    fetchOrders(refresh: true);
  }
}

final myOrdersNotifierProvider =
    NotifierProvider<MyOrdersNotifier, MyOrdersState>(MyOrdersNotifier.new);
