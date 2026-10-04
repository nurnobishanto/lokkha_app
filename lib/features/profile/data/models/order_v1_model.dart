import 'dart:convert';
import 'package:intl/intl.dart';

/// Helper to safely parse numeric values to double
double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }
  return 0.0;
}

/// Helper to safely parse int values
int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val) ?? 0;
  }
  return 0;
}

/// Response model for GET /api/v1/user/orders
class OrderV1ListResponse {
  final bool success;
  final String? message;
  final List<OrderV1Item> items;
  final OrderV1FilterCounts filterCounts;
  final OrderV1Meta meta;

  OrderV1ListResponse({
    this.success = true,
    this.message,
    required this.items,
    required this.filterCounts,
    required this.meta,
  });

  factory OrderV1ListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final rawCounts = data['filter_counts'] as Map<String, dynamic>? ?? {};
    final rawMeta = json['meta'] as Map<String, dynamic>? ?? {};

    return OrderV1ListResponse(
      success: json['success'] == true || json['status'] == true,
      message: json['message']?.toString(),
      items: rawItems.map((e) => OrderV1Item.fromJson(e as Map<String, dynamic>)).toList(),
      filterCounts: OrderV1FilterCounts.fromJson(rawCounts),
      meta: OrderV1Meta.fromJson(rawMeta),
    );
  }
}

/// Individual order item in the list
class OrderV1Item {
  final int id;
  final String invoiceNo;
  final String itemTitle;
  final String itemType;
  final double subtotal;
  final double discount;
  final double total;
  final String status;
  final bool isPaid;
  final bool isTrial;
  final String paymentMethod;
  final String transactionId;
  final String? createdAt;
  final String? paidAt;

  OrderV1Item({
    required this.id,
    required this.invoiceNo,
    required this.itemTitle,
    required this.itemType,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.isPaid,
    this.isTrial = false,
    required this.paymentMethod,
    required this.transactionId,
    this.createdAt,
    this.paidAt,
  });

  factory OrderV1Item.fromJson(Map<String, dynamic> json) {
    return OrderV1Item(
      id: _parseInt(json['id']),
      invoiceNo: json['invoice_no']?.toString() ?? '',
      itemTitle: json['item_title']?.toString() ?? '',
      itemType: json['item_type']?.toString() ?? '',
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      total: _parseDouble(json['total']),
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      isPaid: json['is_paid'] == true || json['status'] == 'paid',
      isTrial: json['is_trial'] == true,
      paymentMethod: json['payment_method']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      paidAt: json['paid_at']?.toString(),
    );
  }

  /// Status display text in Bengali
  String get statusBengali {
    switch (status) {
      case 'paid':
        return 'পরিশোধিত';
      case 'pending':
        return 'অপেক্ষমাণ';
      case 'failed':
        return 'ব্যর্থ';
      default:
        return status;
    }
  }

  /// Clean formatted date
  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt!);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }

  /// Date only (for compact card view)
  String get formattedDateOnly {
    if (createdAt == null || createdAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt!);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }

  /// Currency formatted total
  String get formattedTotal {
    if (total == total.roundToDouble()) {
      return '৳ ${total.toInt()}';
    }
    return '৳ ${total.toStringAsFixed(2)}';
  }
}

/// Filter counts badge model
class OrderV1FilterCounts {
  final int all;
  final int paid;
  final int pending;
  final int failed;
  final int package;
  final int course;
  final int exam;

  OrderV1FilterCounts({
    this.all = 0,
    this.paid = 0,
    this.pending = 0,
    this.failed = 0,
    this.package = 0,
    this.course = 0,
    this.exam = 0,
  });

  factory OrderV1FilterCounts.fromJson(Map<String, dynamic> json) {
    return OrderV1FilterCounts(
      all: _parseInt(json['all']),
      paid: _parseInt(json['paid']),
      pending: _parseInt(json['pending']),
      failed: _parseInt(json['failed']),
      package: _parseInt(json['package']),
      course: _parseInt(json['course']),
      exam: _parseInt(json['exam']),
    );
  }
}

/// Pagination metadata
class OrderV1Meta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  OrderV1Meta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.hasMore = false,
  });

  factory OrderV1Meta.fromJson(Map<String, dynamic> json) {
    final curPage = _parseInt(json['current_page']);
    final lPage = _parseInt(json['last_page']);
    return OrderV1Meta(
      currentPage: curPage == 0 ? 1 : curPage,
      lastPage: lPage == 0 ? 1 : lPage,
      perPage: _parseInt(json['per_page']) == 0 ? 10 : _parseInt(json['per_page']),
      total: _parseInt(json['total']),
      hasMore: json['has_more'] == true || (lPage > curPage && curPage > 0),
    );
  }
}

/// Response model for GET /api/v1/user/orders/{id}
class OrderDetailV1Response {
  final bool success;
  final String? message;
  final OrderDetailV1Data? data;

  OrderDetailV1Response({
    this.success = true,
    this.message,
    this.data,
  });

  factory OrderDetailV1Response.fromJson(Map<String, dynamic> json) {
    return OrderDetailV1Response(
      success: json['success'] == true || json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? OrderDetailV1Data.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Order detailed information
class OrderDetailV1Data {
  final int id;
  final String invoiceNo;
  final String itemTitle;
  final String itemType;
  final double subtotal;
  final double discount;
  final double total;
  final String status;
  final bool isPaid;
  final OrderBillingDetails? billingDetails;
  final OrderCoupon? coupon;
  final List<OrderPaymentV1> payments;

  OrderDetailV1Data({
    required this.id,
    required this.invoiceNo,
    required this.itemTitle,
    required this.itemType,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.isPaid,
    this.billingDetails,
    this.coupon,
    this.payments = const [],
  });

  factory OrderDetailV1Data.fromJson(Map<String, dynamic> json) {
    final billing = json['billing_details'] != null
        ? OrderBillingDetails.fromDynamic(json['billing_details'])
        : null;

    OrderCoupon? coup;
    if (json['coupon'] != null && json['coupon'] is Map<String, dynamic>) {
      coup = OrderCoupon.fromJson(json['coupon'] as Map<String, dynamic>);
    }

    final rawPayments = json['payments'] as List<dynamic>? ?? [];
    final paymentsList = rawPayments
        .whereType<Map<String, dynamic>>()
        .map((e) => OrderPaymentV1.fromJson(e))
        .toList();

    return OrderDetailV1Data(
      id: _parseInt(json['id']),
      invoiceNo: json['invoice_no']?.toString() ?? '',
      itemTitle: json['item_title']?.toString() ?? '',
      itemType: json['item_type']?.toString() ?? '',
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      total: _parseDouble(json['total']),
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      isPaid: json['is_paid'] == true || json['status'] == 'paid',
      billingDetails: billing,
      coupon: coup,
      payments: paymentsList,
    );
  }

  /// Status display text in Bengali
  String get statusBengali {
    switch (status) {
      case 'paid':
        return 'পরিশোধিত';
      case 'pending':
        return 'অপেক্ষমাণ';
      case 'failed':
        return 'ব্যর্থ';
      default:
        return status;
    }
  }

  /// Formatted amounts
  String get formattedTotal =>
      total == total.roundToDouble() ? '৳ ${total.toInt()}' : '৳ ${total.toStringAsFixed(2)}';

  String get formattedSubtotal =>
      subtotal == subtotal.roundToDouble() ? '৳ ${subtotal.toInt()}' : '৳ ${subtotal.toStringAsFixed(2)}';

  String get formattedDiscount =>
      discount == discount.roundToDouble() ? '৳ ${discount.toInt()}' : '৳ ${discount.toStringAsFixed(2)}';

  /// Check if order has any actionable pending payment URL
  String? get activePaymentUrl {
    for (final p in payments) {
      if (p.paymentUrl != null && p.paymentUrl!.isNotEmpty) {
        return p.paymentUrl;
      }
    }
    return null;
  }
}

/// Billing customer details
class OrderBillingDetails {
  final String? name;
  final String? email;
  final String? phone;

  OrderBillingDetails({this.name, this.email, this.phone});

  factory OrderBillingDetails.fromDynamic(dynamic data) {
    if (data == null) return OrderBillingDetails();

    if (data is Map) {
      return OrderBillingDetails.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    if (data is String) {
      final trimmed = data.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map) {
            return OrderBillingDetails.fromJson(
              Map<String, dynamic>.from(decoded),
            );
          }
        } catch (_) {}
      }
      return OrderBillingDetails(name: trimmed);
    }

    return OrderBillingDetails();
  }

  factory OrderBillingDetails.fromJson(Map<String, dynamic> json) {
    String? clean(dynamic val) {
      if (val == null) return null;
      final str = val.toString().trim();
      if (str.isEmpty || str.toLowerCase() == 'null') return null;
      return str;
    }

    return OrderBillingDetails(
      name: clean(json['name']),
      email: clean(json['email']),
      phone: clean(json['phone']),
    );
  }

  bool get hasContent =>
      (name != null && name!.isNotEmpty) ||
      (email != null && email!.isNotEmpty) ||
      (phone != null && phone!.isNotEmpty);
}

/// Applied Coupon details
class OrderCoupon {
  final int? id;
  final String? code;
  final double? value;
  final String? type;

  OrderCoupon({this.id, this.code, this.value, this.type});

  factory OrderCoupon.fromJson(Map<String, dynamic> json) {
    return OrderCoupon(
      id: _parseInt(json['id']),
      code: json['code']?.toString(),
      value: _parseDouble(json['value']),
      type: json['type']?.toString(),
    );
  }
}

/// Payment history record
class OrderPaymentV1 {
  final int? id;
  final double? amount;
  final String? method;
  final String? transactionId;
  final String? status;
  final String? paymentUrl;

  OrderPaymentV1({
    this.id,
    this.amount,
    this.method,
    this.transactionId,
    this.status,
    this.paymentUrl,
  });

  factory OrderPaymentV1.fromJson(Map<String, dynamic> json) {
    return OrderPaymentV1(
      id: _parseInt(json['id']),
      amount: _parseDouble(json['amount']),
      method: json['method']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      status: json['status']?.toString().toLowerCase(),
      paymentUrl: json['payment_url']?.toString(),
    );
  }

  String get statusBengali {
    switch (status) {
      case 'paid':
        return 'পরিশোধিত';
      case 'pending':
        return 'অপেক্ষমাণ';
      case 'failed':
      case 'canceled':
        return 'বাতিল';
      default:
        return status ?? '';
    }
  }

  String get formattedAmount {
    final amt = amount ?? 0.0;
    return amt == amt.roundToDouble() ? '৳ ${amt.toInt()}' : '৳ ${amt.toStringAsFixed(2)}';
  }
}
