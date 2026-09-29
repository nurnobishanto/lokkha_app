// To parse this JSON data, do
//
//     final profileDataModel = profileDataModelFromJson(jsonString);

import 'dart:convert';

import 'package:lokkha/shared/models/user.dart';

ProfileDataModel profileDataModelFromJson(String str) =>
    ProfileDataModel.fromJson(json.decode(str));

String profileDataModelToJson(ProfileDataModel data) =>
    json.encode(data.toJson());

class ProfileDataModel {
  final bool? status;
  final User? user;

  ProfileDataModel({
    this.status,
    this.user,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    User? parsedUser;
    if (json["data"] != null && json["data"] is Map) {
      final dataMap = json["data"] as Map<String, dynamic>;
      if (dataMap["user"] != null && dataMap["user"] is Map) {
        parsedUser = User.fromJson(dataMap["user"] as Map<String, dynamic>);
      } else {
        parsedUser = User.fromJson(dataMap);
      }
    } else if (json["user"] != null && json["user"] is Map) {
      parsedUser = User.fromJson(json["user"] as Map<String, dynamic>);
    }
    return ProfileDataModel(
      status: json["status"] == true || json["status"] == 1,
      user: parsedUser,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": user?.toJson(),
      };
}
