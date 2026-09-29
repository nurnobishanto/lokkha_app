import 'dart:convert';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/shared/models/vocabulary.dart';

VocabularyModel vocabularyModelFromJson(String str) =>
    VocabularyModel.fromJson(json.decode(str));
String vocabularyModelToJson(VocabularyModel data) =>
    json.encode(data.toJson());

class VocabularyModel {
  final bool? status;
  final Vocabularies? vocabularies;
  final List<Category>? types;
  final List<Category>? categories;
  final List<String>? alphabets;
  final String? selectedAlphabet;

  VocabularyModel({
    this.status,
    this.vocabularies,
    this.types,
    this.categories,
    this.alphabets,
    this.selectedAlphabet,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) =>
      VocabularyModel(
        status: json["status"],
        vocabularies: json["vocabularies"] == null
            ? null
            : Vocabularies.fromJson(json["vocabularies"]),
        types: json["types"] == null
            ? []
            : List<Category>.from(
                json["types"]!.map((x) => Category.fromJson(x))),
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
        alphabets: json["alphabets"] == null
            ? []
            : List<String>.from(json["alphabets"]!.map((x) => x)),
        selectedAlphabet: json["selected_alphabet"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "vocabularies": vocabularies?.toJson(),
        "types": types == null
            ? []
            : List<dynamic>.from(types!.map((x) => x.toJson())),
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "alphabets": alphabets == null
            ? []
            : List<dynamic>.from(alphabets!.map((x) => x)),
        "selected_alphabet": selectedAlphabet,
      };
}

class Vocabularies {
  final int? currentPage;
  final List<Vocabulary>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final dynamic nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  Vocabularies({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Vocabularies.fromJson(Map<String, dynamic> json) => Vocabularies(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<Vocabulary>.from(
                json["data"]!.map((x) => Vocabulary.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": links == null
            ? []
            : List<dynamic>.from(links!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class Link {
  final String? url;
  final String? label;
  final bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
