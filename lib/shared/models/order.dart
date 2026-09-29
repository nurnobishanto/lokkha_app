import 'package:lokkha/shared/models/coupon.dart';
import 'package:lokkha/shared/models/course.dart';
import 'package:lokkha/shared/models/payment.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/shared/models/package.dart';

class Order {
  final int? id;
  final String? invoiceNo;
  final int? userId;
  final int? modelId;
  final String? modelType;
  final int? couponId;
  final int? userPackageId;
  final String? paymentMethod;
  final dynamic transactionId;
  final String? status;
  final dynamic subtotal;
  final dynamic discount;
  final dynamic total;
  final String? billingDetails;
  final dynamic paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final Package? package;
  final User? user;
  final List<Payment>? payments;
  final Coupon? coupon;
  final Course? course;

  Order({
    this.id,
    this.invoiceNo,
    this.userId,
    this.modelId,
    this.modelType,
    this.couponId,
    this.userPackageId,
    this.paymentMethod,
    this.transactionId,
    this.status,
    this.subtotal,
    this.discount,
    this.total,
    this.billingDetails,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.package,
    this.user,
    this.payments,
    this.coupon,
    this.course,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final modelType = json['model_type']?.toString() ?? '';

    Package? pkg;
    Course? crs;

    if (modelType == 'App\\Models\\Package') {
      pkg = json['model'] != null ? Package.fromJson(json['model']) : null;
    } else if (modelType == 'App\\Models\\Course') {
      crs = json['model'] != null ? Course.fromJson(json['model']) : null;
    }

    return Order(
      id: json["id"],
      invoiceNo: json["invoice_no"]?.toString(),
      userId: json["user_id"],
      modelId: json["model_id"],
      modelType: modelType,
      couponId: json["coupon_id"],
      userPackageId: json["user_package_id"],
      paymentMethod: json["payment_method"]?.toString(),
      transactionId: json["transaction_id"]?.toString(),
      status: json["status"]?.toString(),
      subtotal: double.tryParse(json["subtotal"]?.toString() ?? '') ?? 0,
      discount: double.tryParse(json["discount"]?.toString() ?? '') ?? 0,
      total: double.tryParse(json["total"]?.toString() ?? '') ?? 0,
      billingDetails: json["billing_details"],
      paidAt: json["paid_at"]?.toString(),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"]),
      deletedAt: json["deleted_at"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      payments: json["payments"] == null
          ? []
          : List<Payment>.from(
              json["payments"].map((x) => Payment.fromJson(x))),
      coupon: json["coupon"] == null ? null : Coupon.fromJson(json["coupon"]),
      package: pkg,
      course: crs,
    );
  }
  String get displayName {
    if (modelType == 'App\\Models\\Package') {
      return package?.name ?? '';
    } else if (modelType == 'App\\Models\\Course') {
      return course?.title ?? '';
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_no": invoiceNo,
        "user_id": userId,
        "model_id": modelId,
        "model_type": modelType,
        "coupon_id": couponId,
        "user_package_id": userPackageId,
        "payment_method": paymentMethod,
        "transaction_id": transactionId,
        "status": status,
        "subtotal": subtotal,
        "discount": discount,
        "total": total,
        "billing_details": billingDetails,
        "paid_at": paidAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "user": user?.toJson(),
        "package": package?.toJson(),
        "payments": payments == null
            ? []
            : List<dynamic>.from(payments!.map((x) => x.toJson())),
        "coupon": coupon?.toJson(),
        "model": course?.toJson(),
      };
}
