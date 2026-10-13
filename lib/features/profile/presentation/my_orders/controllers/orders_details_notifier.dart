import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/models/order_v1_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_order_details_usecase.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class OrdersDetailsState {
  final bool isLoading;
  final bool hasError;
  final OrderDetailV1Data? orderDetail;

  const OrdersDetailsState({
    this.isLoading = true,
    this.hasError = false,
    this.orderDetail,
  });

  OrdersDetailsState copyWith({
    bool? isLoading,
    bool? hasError,
    OrderDetailV1Data? orderDetail,
  }) {
    return OrdersDetailsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      orderDetail: orderDetail ?? this.orderDetail,
    );
  }
}

class OrdersDetailsNotifier extends Notifier<OrdersDetailsState> {
  final dynamic id;
  final String? url;
  final GetOrderDetailsUseCase? _injectedUseCase;
  late final GetOrderDetailsUseCase _getOrderDetailsUseCase;

  OrdersDetailsNotifier({this.id, this.url, GetOrderDetailsUseCase? getOrderDetailsUseCase})
      : _injectedUseCase = getOrderDetailsUseCase;

  @override
  OrdersDetailsState build() {
    _getOrderDetailsUseCase = _injectedUseCase ?? GetOrderDetailsUseCase();
    if (id != null || url != null) {
      Future.microtask(() => fetchOrdersDetails(id: id, url: url));
    }
    return const OrdersDetailsState(
      isLoading: true,
      hasError: false,
    );
  }

  Future<void> fetchOrdersDetails({dynamic id, String? url}) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
    );

    try {
      dynamic orderId = id;
      if (orderId == null && url != null && url.isNotEmpty) {
        final uri = Uri.tryParse(url);
        if (uri != null && uri.pathSegments.isNotEmpty) {
          orderId = uri.pathSegments.last;
        } else {
          final match = RegExp(r'\d+').allMatches(url).lastOrNull;
          if (match != null) {
            orderId = match.group(0);
          }
        }
      }

      if (orderId == null) {
        throw Exception('Order ID not provided');
      }

      final data = await _getOrderDetailsUseCase(orderId);
      state = state.copyWith(
        isLoading: false,
        hasError: false,
        orderDetail: data,
      );
    } catch (e) {
      debugPrint('[OrdersDetailsNotifier] fetchOrdersDetails error: $e');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
      CustomSnackBar.showCustomErrorToast(
        message: "অর্ডার তথ্য লোড করতে সমস্যা হয়েছে",
      );
    }
  }
}

typedef OrderDetailsParam = ({dynamic id, String? url});

final ordersDetailsNotifierProvider = NotifierProvider.family<
    OrdersDetailsNotifier, OrdersDetailsState, OrderDetailsParam>(
  (arg) => OrdersDetailsNotifier(id: arg.id, url: arg.url),
);
