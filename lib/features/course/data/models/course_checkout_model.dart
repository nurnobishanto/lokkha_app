import 'dart:convert';

import 'package:lokkha/shared/models/order.dart';
import 'package:lokkha/shared/models/payment.dart';

CourseCheckoutModel packageCheckoutModelFromJson(String str) =>
    CourseCheckoutModel.fromJson(json.decode(str));

String packageCheckoutModelToJson(CourseCheckoutModel data) =>
    json.encode(data.toJson());

class CourseCheckoutModel {
  final bool? status;
  final Order? order;
  final Payment? payment;
  final String? paymentUrl;

  CourseCheckoutModel({
    this.status,
    this.order,
    this.payment,
    this.paymentUrl,
  });

  factory CourseCheckoutModel.fromJson(Map<String, dynamic> json) =>
      CourseCheckoutModel(
        status: json["status"],
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
        payment:
            json["payment"] == null ? null : Payment.fromJson(json["payment"]),
        paymentUrl: json["payment_url"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "order": order?.toJson(),
        "payment": payment?.toJson(),
        "payment_url": paymentUrl,
      };
}
