import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/profile/data/models/order_v1_model.dart';
import 'package:lokkha/features/profile/domain/repositories/profile_repository.dart';
import 'package:lokkha/features/profile/domain/usecases/get_order_details_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/get_user_orders_usecase.dart';
import 'package:lokkha/features/profile/presentation/my_orders/riverpod/my_orders_notifier.dart';
import 'package:lokkha/features/profile/presentation/my_orders/riverpod/orders_details_notifier.dart';

class MockProfileRepository implements ProfileRepository {
  final OrderV1ListResponse mockListResponse;
  final OrderDetailV1Data mockDetailData;

  MockProfileRepository({
    required this.mockListResponse,
    required this.mockDetailData,
  });

  @override
  Future<OrderV1ListResponse> getUserOrders({
    String status = 'all',
    String modelType = 'all',
    String paymentMethod = 'all',
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    return mockListResponse;
  }

  @override
  Future<OrderDetailV1Data> getOrderDetails(dynamic id) async {
    return mockDetailData;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleOrdersListJson = {
    "success": true,
    "message": "Orders retrieved successfully.",
    "data": {
      "items": [
        {
          "id": 105,
          "invoice_no": "ORD-2026A-4921-105",
          "item_title": "BCS 6 Month Premium Subscription",
          "item_type": "Subscription Package",
          "subtotal": 1200.00,
          "discount": 200.00,
          "total": 1000.00,
          "status": "paid",
          "is_paid": true,
          "is_trial": false,
          "payment_method": "bkash",
          "transaction_id": "TRX9402831",
          "created_at": "2026-09-10 15:40:22",
          "paid_at": "2026-09-10 15:42:01"
        }
      ],
      "filter_counts": {
        "all": 5,
        "paid": 4,
        "pending": 1,
        "failed": 0,
        "package": 3,
        "course": 1,
        "exam": 1
      }
    },
    "meta": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 10,
      "total": 5,
      "has_more": false
    }
  };

  const sampleOrderDetailJson = {
    "success": true,
    "message": "Order details retrieved successfully.",
    "data": {
      "id": 105,
      "invoice_no": "ORD-2026A-4921-105",
      "item_title": "BCS 6 Month Premium Subscription",
      "item_type": "Subscription Package",
      "subtotal": 1200.00,
      "discount": 200.00,
      "total": 1000.00,
      "status": "paid",
      "is_paid": true,
      "billing_details": {
        "name": "Arif Ahmed",
        "phone": "01712345678"
      },
      "coupon": {
        "id": 2,
        "code": "EID200",
        "value": 200.00,
        "type": "fixed"
      },
      "payments": [
        {
          "id": 99,
          "amount": 1000.00,
          "method": "bkash",
          "transaction_id": "TRX9402831",
          "status": "paid",
          "payment_url": "https://lokkha.com/payment/99"
        }
      ]
    }
  };

  group('Order V1 List & Details Model Tests', () {
    test('OrderV1ListResponse parses list, filter counts, and pagination meta', () {
      final response = OrderV1ListResponse.fromJson(sampleOrdersListJson);

      expect(response.success, true);
      expect(response.message, 'Orders retrieved successfully.');
      expect(response.items.length, 1);

      final item = response.items.first;
      expect(item.id, 105);
      expect(item.invoiceNo, 'ORD-2026A-4921-105');
      expect(item.itemTitle, 'BCS 6 Month Premium Subscription');
      expect(item.itemType, 'Subscription Package');
      expect(item.subtotal, 1200.00);
      expect(item.discount, 200.00);
      expect(item.total, 1000.00);
      expect(item.status, 'paid');
      expect(item.statusBengali, 'পরিশোধিত');
      expect(item.isPaid, true);
      expect(item.isTrial, false);
      expect(item.paymentMethod, 'bkash');
      expect(item.transactionId, 'TRX9402831');
      expect(item.formattedTotal, '৳ 1000');

      // Filter Counts
      expect(response.filterCounts.all, 5);
      expect(response.filterCounts.paid, 4);
      expect(response.filterCounts.pending, 1);
      expect(response.filterCounts.failed, 0);
      expect(response.filterCounts.package, 3);
      expect(response.filterCounts.course, 1);
      expect(response.filterCounts.exam, 1);

      // Meta
      expect(response.meta.currentPage, 1);
      expect(response.meta.lastPage, 1);
      expect(response.meta.perPage, 10);
      expect(response.meta.total, 5);
      expect(response.meta.hasMore, false);
    });

    test('OrderDetailV1Response parses complete details with coupon and payments', () {
      final response = OrderDetailV1Response.fromJson(sampleOrderDetailJson);

      expect(response.success, true);
      expect(response.data, isNotNull);

      final data = response.data!;
      expect(data.id, 105);
      expect(data.invoiceNo, 'ORD-2026A-4921-105');
      expect(data.itemTitle, 'BCS 6 Month Premium Subscription');
      expect(data.itemType, 'Subscription Package');
      expect(data.subtotal, 1200.00);
      expect(data.discount, 200.00);
      expect(data.total, 1000.00);
      expect(data.status, 'paid');
      expect(data.statusBengali, 'পরিশোধিত');
      expect(data.isPaid, true);

      // Billing Details
      expect(data.billingDetails, isNotNull);
      expect(data.billingDetails!.name, 'Arif Ahmed');
      expect(data.billingDetails!.phone, '01712345678');

      // Coupon Details
      expect(data.coupon, isNotNull);
      expect(data.coupon!.id, 2);
      expect(data.coupon!.code, 'EID200');
      expect(data.coupon!.value, 200.00);
      expect(data.coupon!.type, 'fixed');

      // Payments
      expect(data.payments.length, 1);
      final payment = data.payments.first;
      expect(payment.id, 99);
      expect(payment.amount, 1000.00);
      expect(payment.method, 'bkash');
      expect(payment.transactionId, 'TRX9402831');
      expect(payment.status, 'paid');
      expect(payment.statusBengali, 'পরিশোধিত');
      expect(payment.paymentUrl, 'https://lokkha.com/payment/99');
      expect(data.activePaymentUrl, 'https://lokkha.com/payment/99');
    });

    test('OrderDetailV1Response handles stringified JSON billing details correctly', () {
      final jsonWithStringBilling = Map<String, dynamic>.from(sampleOrderDetailJson);
      final dataMap = Map<String, dynamic>.from(jsonWithStringBilling['data'] as Map);
      dataMap['billing_details'] = '{"name":"sadman.","email":null,"phone":"8801749784788"}';
      jsonWithStringBilling['data'] = dataMap;

      final response = OrderDetailV1Response.fromJson(jsonWithStringBilling);
      expect(response.data, isNotNull);
      final billing = response.data!.billingDetails;
      expect(billing, isNotNull);
      expect(billing!.name, 'sadman.');
      expect(billing.email, isNull);
      expect(billing.phone, '8801749784788');
      expect(billing.hasContent, true);
    });
  });

  group('Order Notifiers & UseCases Clean Architecture Tests', () {
    late MockProfileRepository mockRepo;
    late GetUserOrdersUseCase getUserOrdersUseCase;
    late GetOrderDetailsUseCase getOrderDetailsUseCase;

    setUp(() {
      final listResp = OrderV1ListResponse.fromJson(sampleOrdersListJson);
      final detailResp = OrderDetailV1Response.fromJson(sampleOrderDetailJson);

      mockRepo = MockProfileRepository(
        mockListResponse: listResp,
        mockDetailData: detailResp.data!,
      );

      getUserOrdersUseCase = GetUserOrdersUseCase(repository: mockRepo);
      getOrderDetailsUseCase = GetOrderDetailsUseCase(repository: mockRepo);
    });

    test('MyOrdersNotifier fetches orders and updates filter counts', () async {
      final container = ProviderContainer(
        overrides: [
          myOrdersNotifierProvider.overrideWith(
            () => MyOrdersNotifier(getUserOrdersUseCase: getUserOrdersUseCase),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(myOrdersNotifierProvider.notifier);
      await notifier.fetchOrders(refresh: true);

      var state = container.read(myOrdersNotifierProvider);
      expect(state.orders.length, 1);
      expect(state.orders.first.invoiceNo, 'ORD-2026A-4921-105');
      expect(state.filterCounts.all, 5);
      expect(state.filterCounts.paid, 4);
      expect(state.filterCounts.pending, 1);

      // Change status filter
      notifier.setStatusFilter('paid');
      state = container.read(myOrdersNotifierProvider);
      expect(state.selectedStatus, 'paid');

      // Change model type filter
      notifier.setModelTypeFilter('Package');
      state = container.read(myOrdersNotifierProvider);
      expect(state.selectedModelType, 'Package');
    });

    test('OrdersDetailsNotifier fetches order details correctly', () async {
      final container = ProviderContainer(
        overrides: [
          ordersDetailsNotifierProvider((id: 105, url: null)).overrideWith(
            () => OrdersDetailsNotifier(
              id: 105,
              getOrderDetailsUseCase: getOrderDetailsUseCase,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ordersDetailsNotifierProvider((id: 105, url: null)).notifier);
      await notifier.fetchOrdersDetails(id: 105);

      final state = container.read(ordersDetailsNotifierProvider((id: 105, url: null)));
      expect(state.isLoading, false);
      expect(state.orderDetail, isNotNull);
      expect(state.orderDetail!.id, 105);
      expect(state.orderDetail!.billingDetails!.name, 'Arif Ahmed');
      expect(state.orderDetail!.coupon!.code, 'EID200');
    });
  });
}
