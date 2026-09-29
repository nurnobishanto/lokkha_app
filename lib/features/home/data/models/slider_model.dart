// To parse this JSON data, do
//
//     final sliderModel = sliderModelFromJson(jsonString);

import 'dart:convert';

SliderModel sliderModelFromJson(String str) =>
    SliderModel.fromJson(json.decode(str));

String sliderModelToJson(SliderModel data) => json.encode(data.toJson());

class SliderModel {
  final bool? status;
  final List<Slider>? sliders;

  SliderModel({
    this.status,
    this.sliders,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) => SliderModel(
        status: json["status"],
        sliders: json["sliders"] == null
            ? []
            : List<Slider>.from(
                json["sliders"]!.map((x) => Slider.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "sliders": sliders == null
            ? []
            : List<dynamic>.from(sliders!.map((x) => x.toJson())),
      };
}

class Slider {
  final int? id;
  final String? image;
  final String? type;
  final int? sorting;
  final bool? status;
  final String? link;
  final String? page;
  final dynamic param;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  Slider({
    this.id,
    this.image,
    this.type,
    this.sorting,
    this.status,
    this.link,
    this.page,
    this.param,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Slider.fromJson(Map<String, dynamic> json) => Slider(
        id: json["id"],
        image: json["image"],
        type: json["type"],
        sorting: json["sorting"],
        status: json["status"],
        link: json["link"],
        page: json["page"],
        param: json["param"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "type": type,
        "sorting": sorting,
        "status": status,
        "link": link,
        "page": page,
        "param": param,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
