// To parse this JSON data, do
//
//     final packageCheckoutModel = packageCheckoutModelFromJson(jsonString);

import 'dart:convert';

import 'package:lokkha/shared/models/order.dart';
import 'package:lokkha/shared/models/payment.dart';

PackageCheckoutModel packageCheckoutModelFromJson(String str) =>
    PackageCheckoutModel.fromJson(json.decode(str));

String packageCheckoutModelToJson(PackageCheckoutModel data) =>
    json.encode(data.toJson());

class PackageCheckoutModel {
  final bool? status;
  final Order? order;
  final Payment? payment;
  final String? paymentUrl;

  PackageCheckoutModel({
    this.status,
    this.order,
    this.payment,
    this.paymentUrl,
  });

  factory PackageCheckoutModel.fromJson(Map<String, dynamic> json) =>
      PackageCheckoutModel(
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
