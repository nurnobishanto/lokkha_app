import 'dart:convert';
import 'package:lokkha/shared/models/package.dart';

PackageDetailResponseModel packageDetailResponseModelFromJson(String str) =>
    PackageDetailResponseModel.fromJson(
        json.decode(str) as Map<String, dynamic>);

String packageDetailResponseModelToJson(PackageDetailResponseModel data) =>
    json.encode(data.toJson());

class PackageDetailResponseModel {
  final bool success;
  final String? message;
  final Package? package;

  PackageDetailResponseModel({
    this.success = false,
    this.message,
    this.package,
  });

  factory PackageDetailResponseModel.fromJson(Map<String, dynamic> json) {
    Package? pkg;
    final rawData = json["data"];
    if (rawData is Map<String, dynamic>) {
      if (rawData["package"] is Map<String, dynamic>) {
        pkg = Package.fromJson(rawData["package"]);
      } else {
        pkg = Package.fromJson(rawData);
      }
    } else if (json["package"] is Map<String, dynamic>) {
      pkg = Package.fromJson(json["package"]);
    }

    final isSuccess = json["success"] == true ||
        json["status"] == true ||
        json["status"]?.toString().toLowerCase() == "success";

    return PackageDetailResponseModel(
      success: isSuccess,
      message: json["message"]?.toString(),
      package: pkg,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": package?.toJson(),
      };
}
