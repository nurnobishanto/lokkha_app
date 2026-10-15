import 'category.dart';

class Vocabulary {
  final int? id;
  final String? word;
  final String? details;
  final List<String?>? synonym;
  final List<String?>? antonym;
  final List<String?>? wrongSynonym;
  final List<String?>? wrongAntonym;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Category>? types;
  final List<Category>? categories;
  final String? typeName;
  final String? categoryName;

  Vocabulary({
    this.id,
    this.word,
    this.details,
    this.synonym,
    this.antonym,
    this.wrongSynonym,
    this.wrongAntonym,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.types,
    this.categories,
    this.typeName,
    this.categoryName,
  });

  // Convenient aliases for v1 API compatibility
  List<String?>? get synonyms => synonym;
  List<String?>? get antonyms => antonym;
  String? get type => typeName;
  String? get category => categoryName;

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    // Parse synonyms (supports v1 'synonyms' and legacy 'synonym')
    final rawSynonyms = json["synonyms"] ?? json["synonym"];
    List<String?> parsedSynonyms = [];
    if (rawSynonyms is List) {
      parsedSynonyms = rawSynonyms.map((x) => x?.toString()).toList();
    }

    // Parse antonyms (supports v1 'antonyms' and legacy 'antonym')
    final rawAntonyms = json["antonyms"] ?? json["antonym"];
    List<String?> parsedAntonyms = [];
    if (rawAntonyms is List) {
      parsedAntonyms = rawAntonyms.map((x) => x?.toString()).toList();
    }

    // Parse wrong synonyms
    final rawWrongSyn = json["wrong_synonyms"] ?? json["wrong_synonym"];
    List<String?> parsedWrongSyn = [];
    if (rawWrongSyn is List) {
      parsedWrongSyn = rawWrongSyn.map((x) => x?.toString()).toList();
    }

    // Parse wrong antonyms
    final rawWrongAnt = json["wrong_antonyms"] ?? json["wrong_antonym"];
    List<String?> parsedWrongAnt = [];
    if (rawWrongAnt is List) {
      parsedWrongAnt = rawWrongAnt.map((x) => x?.toString()).toList();
    }

    // Parse type (supports v1 string 'type' and legacy list 'types')
    String? parsedTypeName;
    List<Category> parsedTypes = [];
    if (json["type"] is String) {
      parsedTypeName = json["type"] as String;
    } else if (json["types"] is List) {
      parsedTypes = List<Category>.from(
        (json["types"] as List)
            .whereType<Map<String, dynamic>>()
            .map((x) => Category.fromJson(x)),
      );
      if (parsedTypes.isNotEmpty) {
        parsedTypeName = parsedTypes.first.name;
      }
    }

    // Parse category (supports v1 string 'category' and legacy list 'categories')
    String? parsedCategoryName;
    List<Category> parsedCategories = [];
    if (json["category"] is String) {
      parsedCategoryName = json["category"] as String;
    } else if (json["categories"] is List) {
      parsedCategories = List<Category>.from(
        (json["categories"] as List)
            .whereType<Map<String, dynamic>>()
            .map((x) => Category.fromJson(x)),
      );
      if (parsedCategories.isNotEmpty) {
        parsedCategoryName = parsedCategories.first.name;
      }
    }

    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      try {
        return DateTime.parse(d.toString());
      } catch (_) {
        return null;
      }
    }

    return Vocabulary(
      id: json["id"] is int
          ? json["id"] as int
          : int.tryParse(json["id"]?.toString() ?? ''),
      word: json["word"]?.toString(),
      details: json["details"]?.toString(),
      synonym: parsedSynonyms,
      antonym: parsedAntonyms,
      wrongSynonym: parsedWrongSyn,
      wrongAntonym: parsedWrongAnt,
      status: json["status"]?.toString(),
      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
      types: parsedTypes,
      categories: parsedCategories,
      typeName: parsedTypeName,
      categoryName: parsedCategoryName,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "word": word,
        "details": details,
        "synonym": synonym ?? [],
        "synonyms": synonym ?? [],
        "antonym": antonym ?? [],
        "antonyms": antonym ?? [],
        "wrong_synonym": wrongSynonym ?? [],
        "wrong_antonym": wrongAntonym ?? [],
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "types": types?.map((x) => x.toJson()).toList() ?? [],
        "categories": categories?.map((x) => x.toJson()).toList() ?? [],
        "type": typeName,
        "category": categoryName,
      };
}
