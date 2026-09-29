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
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) => Vocabulary(
        id: json["id"],
        word: json["word"],
        details: json["details"],
        synonym: json["synonym"] == null
            ? []
            : List<String?>.from(json["synonym"]!.map((x) => x)),
        antonym: json["antonym"] == null
            ? []
            : List<String?>.from(json["antonym"]!.map((x) => x)),
        wrongSynonym: json["wrong_synonym"] == null
            ? []
            : List<String?>.from(json["wrong_synonym"]!.map((x) => x)),
        wrongAntonym: json["wrong_antonym"] == null
            ? []
            : List<String?>.from(json["wrong_antonym"]!.map((x) => x)),
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        types: json["types"] == null
            ? []
            : List<Category>.from(
                json["types"]!.map((x) => Category.fromJson(x))),
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "word": word,
        "details": details,
        "synonym":
            synonym == null ? [] : List<dynamic>.from(synonym!.map((x) => x)),
        "antonym":
            antonym == null ? [] : List<dynamic>.from(antonym!.map((x) => x)),
        "wrong_synonym": wrongSynonym == null
            ? []
            : List<dynamic>.from(wrongSynonym!.map((x) => x)),
        "wrong_antonym": wrongAntonym == null
            ? []
            : List<dynamic>.from(wrongAntonym!.map((x) => x)),
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "types": types == null
            ? []
            : List<dynamic>.from(types!.map((x) => x.toJson())),
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
      };
}
