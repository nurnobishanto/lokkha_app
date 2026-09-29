import 'dart:convert';

import 'package:lokkha/shared/models/package.dart';

PremiumPackageModel premiumPackageModelFromJson(String str) =>
    PremiumPackageModel.fromJson(json.decode(str));

String premiumPackageModelToJson(PremiumPackageModel data) =>
    json.encode(data.toJson());

class PremiumPackageModel {
  final bool? status;
  final List<Package>? packages;

  PremiumPackageModel({
    this.status,
    this.packages,
  });

  factory PremiumPackageModel.fromJson(Map<String, dynamic> json) =>
      PremiumPackageModel(
        status: json["status"],
        packages: json["packages"] == null
            ? []
            : List<Package>.from(
                json["packages"]!.map((x) => Package.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "packages": packages == null
            ? []
            : List<dynamic>.from(packages!.map((x) => x.toJson())),
      };
}
