import 'dart:convert';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/shared/models/vocabulary.dart';

VocabularyModel vocabularyModelFromJson(String str) =>
    VocabularyModel.fromJson(json.decode(str));
String vocabularyModelToJson(VocabularyModel data) =>
    json.encode(data.toJson());

class VocabularyModel {
  final bool? status;
  final bool? success;
  final String? message;
  final Vocabularies? vocabularies;
  final List<Category>? types;
  final List<Category>? categories;
  final List<String>? alphabets;
  final String? selectedAlphabet;

  VocabularyModel({
    this.status,
    this.success,
    this.message,
    this.vocabularies,
    this.types,
    this.categories,
    this.alphabets,
    this.selectedAlphabet,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    // Check if response is wrapped in standard v1 `data` envelope
    final Map<String, dynamic> rootData = (json["data"] is Map<String, dynamic>)
        ? json["data"] as Map<String, dynamic>
        : (json["data"] is Map ? Map<String, dynamic>.from(json["data"] as Map) : json);

    final bool statusVal = json["success"] == true ||
        json["status"] == true ||
        rootData["status"] == true;

    // Vocabularies extraction
    Vocabularies? vocabulariesObj;
    if (json["vocabularies"] != null && json["vocabularies"] is Map) {
      vocabulariesObj = Vocabularies.fromJson(
        json["vocabularies"] is Map<String, dynamic>
            ? json["vocabularies"] as Map<String, dynamic>
            : Map<String, dynamic>.from(json["vocabularies"] as Map),
      );
    } else if (rootData["vocabularies"] != null && rootData["vocabularies"] is Map) {
      vocabulariesObj = Vocabularies.fromJson(
        rootData["vocabularies"] is Map<String, dynamic>
            ? rootData["vocabularies"] as Map<String, dynamic>
            : Map<String, dynamic>.from(rootData["vocabularies"] as Map),
      );
    } else {
      // V1 API puts items in `items`
      final rawItems = rootData["items"] ?? json["items"];
      List<Vocabulary> parsedItems = [];
      if (rawItems is List) {
        parsedItems = rawItems
            .whereType<Map>()
            .map((x) => Vocabulary.fromJson(
                  x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x),
                ))
            .toList();
      }

      final pagination = json["meta"] ?? json["pagination"] ?? rootData["pagination"] ?? rootData["meta"];
      int curPage = 1;
      int lastPage = 1;
      int totalCount = parsedItems.length;
      int perPage = 20;

      if (pagination is Map) {
        curPage = int.tryParse(pagination["current_page"]?.toString() ?? '') ?? 1;
        lastPage = int.tryParse(pagination["last_page"]?.toString() ?? pagination["total_pages"]?.toString() ?? '') ?? 1;
        totalCount = int.tryParse(pagination["total"]?.toString() ?? '') ?? parsedItems.length;
        perPage = int.tryParse(pagination["per_page"]?.toString() ?? '') ?? 20;
      }

      vocabulariesObj = Vocabularies(
        currentPage: curPage,
        lastPage: lastPage,
        total: totalCount,
        perPage: perPage,
        data: parsedItems,
      );
    }

    // Types extraction
    final rawTypes = rootData["types"] ?? json["types"];
    List<Category> parsedTypes = [];
    if (rawTypes is List) {
      parsedTypes = rawTypes
          .whereType<Map>()
          .map((x) => Category.fromJson(
                x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x),
              ))
          .toList();
    }

    // Categories extraction
    final rawCategories = rootData["categories"] ?? json["categories"];
    List<Category> parsedCategories = [];
    if (rawCategories is List) {
      parsedCategories = rawCategories
          .whereType<Map>()
          .map((x) => Category.fromJson(
                x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x),
              ))
          .toList();
    }

    // Alphabets extraction
    final rawAlphabets = rootData["alphabets"] ?? json["alphabets"];
    List<String> parsedAlphabets = [];
    if (rawAlphabets is List) {
      parsedAlphabets = rawAlphabets.map((x) => x.toString()).toList();
    }

    final selectedAlpha =
        (rootData["selected_alphabet"] ?? json["selected_alphabet"])?.toString();

    return VocabularyModel(
      status: statusVal,
      success: json["success"] == true || statusVal,
      message: json["message"]?.toString() ?? '',
      vocabularies: vocabulariesObj,
      types: parsedTypes,
      categories: parsedCategories,
      alphabets: parsedAlphabets,
      selectedAlphabet: selectedAlpha,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "message": message,
        "vocabularies": vocabularies?.toJson(),
        "types": types?.map((x) => x.toJson()).toList() ?? [],
        "categories": categories?.map((x) => x.toJson()).toList() ?? [],
        "alphabets": alphabets ?? [],
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
