import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/study_material/data/models/current_affairs_model.dart';
import 'package:lokkha/shared/models/question.dart';

void main() {
  group('Current Affairs & Question Option Parsing Tests', () {
    test('Option parses string key ("A", "B", etc.) without type errors', () {
      final json = {
        "key": "A",
        "value": "ভারত",
        "is_correct": false,
      };

      final option = Option.fromJson(json);
      expect(option.key, "A");
      expect(option.keyAsString, "A");
      expect(option.value, "ভারত");
      expect(option.isCorrect, false);
    });

    test('Option parses integer key (1, 2, etc.) and boolean equivalents correctly', () {
      final json = {
        "key": 1,
        "value": "বাংলাদেশ",
        "is_correct": 1, // numeric boolean representation
      };

      final option = Option.fromJson(json);
      expect(option.key, 1);
      expect(option.keyAsString, "1");
      expect(option.keyAsInt, 1);
      expect(option.value, "বাংলাদেশ");
      expect(option.isCorrect, true);
    });

    test('CurrentAffairsModel parses exact API response payload safely', () {
      final apiResponse = {
        "status": true,
        "message": "National current affairs retrieved successfully.",
        "current_affairs": {
          "current_page": 1,
          "per_page": 15,
          "total": 30,
          "last_page": 2,
          "data": [
            {
              "date": "2026-09-27T18:00:00.000000Z",
              "questions": [
                {
                  "id": 85611,
                  "question_type": "single_choice",
                  "title": "<p>দক্ষিণ এশিয়ার প্রথম দেশ হিসেবে জাতিসংঘের পানি কনভেনশনে যোগ দেয় কোন দেশ?</p>",
                  "description": null,
                  "options": [
                    {
                      "key": "A",
                      "value": "ভারত",
                      "is_correct": false
                    },
                    {
                      "key": "B",
                      "value": "বাংলাদেশ",
                      "is_correct": true
                    },
                    {
                      "key": "C",
                      "value": "নেপাল",
                      "is_correct": false
                    },
                    {
                      "key": "D",
                      "value": "ভুটান",
                      "is_correct": false
                    }
                  ],
                  "explanation": "<p>বাংলাদেশ ২০ জুন,২০২৬ আনুষ্ঠানিকভাবে জাতিসংঘের...</p>",
                  "question_image": null,
                  "explanation_image": null,
                  "note": null,
                  "reference": null
                }
              ]
            }
          ]
        }
      };

      final model = CurrentAffairsModel.fromJson(apiResponse);

      expect(model.status, true);
      expect(model.message, "National current affairs retrieved successfully.");
      expect(model.currentAffairs, isNotNull);
      expect(model.currentAffairs!.currentPage, 1);
      expect(model.currentAffairs!.data!.length, 1);

      final datum = model.currentAffairs!.data!.first;
      expect(datum.date, "2026-09-27T18:00:00.000000Z");
      expect(datum.questions!.length, 1);

      final question = datum.questions!.first;
      expect(question.id, 85611);
      expect(question.options!.length, 4);
      expect(question.options![0].key, "A");
      expect(question.options![0].value, "ভারত");
      expect(question.options![0].isCorrect, false);
      expect(question.options![1].key, "B");
      expect(question.options![1].value, "বাংলাদেশ");
      expect(question.options![1].isCorrect, true);
    });

    test('CurrentAffairsModel handles null or empty safely without crashing', () {
      final emptyResponse = {
        "status": true,
        "message": "Empty",
        "current_affairs": null,
      };

      final model = CurrentAffairsModel.fromJson(emptyResponse);
      expect(model.currentAffairs, isNull);
    });
  });
}
