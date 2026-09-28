enum QuestionType {
  SINGLE_CHOICE,
  MULTIPLE_CHOICE,
  FILL_IN_THE_BLANK,
}

final questionTypeValues = EnumValues({
  "single_choice": QuestionType.SINGLE_CHOICE,
  "multiple_choice": QuestionType.MULTIPLE_CHOICE,
  "fill_in_the_blank": QuestionType.FILL_IN_THE_BLANK,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
