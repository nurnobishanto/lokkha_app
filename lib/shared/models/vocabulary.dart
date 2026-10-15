import 'category.dart';

class Vocabulary {
  final int? id;
  final String? word;
  final String? pronunciation;
  final String? banglaMeaning;
  final String? meaning;
  final String? details;
  final List<String?>? synonym;
  final List<String?>? antonym;
  final List<String?>? wrongSynonym;
  final List<String?>? wrongAntonym;
  final String? sentenceExample;
  final String? notes;
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
    this.pronunciation,
    this.banglaMeaning,
    this.meaning,
    this.details,
    this.synonym,
    this.antonym,
    this.wrongSynonym,
    this.wrongAntonym,
    this.sentenceExample,
    this.notes,
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

  String? get displayMeaning {
    if (banglaMeaning != null && banglaMeaning!.trim().isNotEmpty) {
      return banglaMeaning;
    }
    if (meaning != null && meaning!.trim().isNotEmpty) {
      return meaning;
    }
    return details;
  }

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    final pronunciation = json["pronunciation"]?.toString();
    final banglaMeaning = json["bangla_meaning"]?.toString();
    final meaning = json["meaning"]?.toString();
    final sentenceExample = json["sentence_example"]?.toString();
    final notes = json["notes"]?.toString();
    final details = json["details"]?.toString() ?? banglaMeaning ?? meaning;

    // Parse synonyms (supports v1 'synonyms' and legacy 'synonym')
    final rawSynonyms = json["synonyms"] ?? json["synonym"];
    List<String?> parsedSynonyms = [];
    if (rawSynonyms is List) {
      parsedSynonyms = rawSynonyms.map((x) => x?.toString()).toList();
    } else if (rawSynonyms is String && rawSynonyms.trim().isNotEmpty) {
      parsedSynonyms = rawSynonyms
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Parse antonyms (supports v1 'antonyms' and legacy 'antonym')
    final rawAntonyms = json["antonyms"] ?? json["antonym"];
    List<String?> parsedAntonyms = [];
    if (rawAntonyms is List) {
      parsedAntonyms = rawAntonyms.map((x) => x?.toString()).toList();
    } else if (rawAntonyms is String && rawAntonyms.trim().isNotEmpty) {
      parsedAntonyms = rawAntonyms
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
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

    // Parse types
    String? parsedTypeName;
    List<Category> parsedTypes = [];
    if (json["type"] is String) {
      parsedTypeName = json["type"] as String;
    } else if (json["types"] is List) {
      parsedTypes = List<Category>.from(
        (json["types"] as List)
            .whereType<Map>()
            .map((x) => Category.fromJson(
                x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x))),
      );
      if (parsedTypes.isNotEmpty) {
        parsedTypeName = parsedTypes
            .map((t) => t.name)
            .where((n) => n != null && n.isNotEmpty)
            .join(', ');
      }
    }

    // Parse categories
    String? parsedCategoryName;
    List<Category> parsedCategories = [];
    if (json["category"] is String) {
      parsedCategoryName = json["category"] as String;
    } else if (json["categories"] is List) {
      parsedCategories = List<Category>.from(
        (json["categories"] as List)
            .whereType<Map>()
            .map((x) => Category.fromJson(
                x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x))),
      );
      if (parsedCategories.isNotEmpty) {
        parsedCategoryName = parsedCategories
            .map((c) => c.name)
            .where((n) => n != null && n.isNotEmpty)
            .join(', ');
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
      pronunciation: pronunciation,
      banglaMeaning: banglaMeaning,
      meaning: meaning,
      details: details,
      synonym: parsedSynonyms,
      antonym: parsedAntonyms,
      wrongSynonym: parsedWrongSyn,
      wrongAntonym: parsedWrongAnt,
      sentenceExample: sentenceExample,
      notes: notes,
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
        "pronunciation": pronunciation,
        "bangla_meaning": banglaMeaning,
        "meaning": meaning,
        "details": details,
        "synonym": synonym ?? [],
        "synonyms": synonym ?? [],
        "antonym": antonym ?? [],
        "antonyms": antonym ?? [],
        "wrong_synonym": wrongSynonym ?? [],
        "wrong_antonym": wrongAntonym ?? [],
        "sentence_example": sentenceExample,
        "notes": notes,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "types": types?.map((x) => x.toJson()).toList() ?? [],
        "categories": categories?.map((x) => x.toJson()).toList() ?? [],
        "type": typeName,
        "category": categoryName,
      };
}
