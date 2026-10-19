import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/exam_provider.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/features/exam/exam.dart';

class MockExamLifecycleRepository implements ExamRepository {
  ExamInstructionsResponse? instructionsToReturn;
  ExamStartResponse? startToReturn;
  ActiveExamSessionResponse? sessionToReturn;
  SaveAnswerResponse? saveAnswerToReturn;
  ExamSubmitResponse? submitToReturn;
  ExamLeaderboardResponse? leaderboardToReturn;

  @override
  Future<ExamInstructionsResponse> getExamInstructions(int examId) async {
    return instructionsToReturn ?? const ExamInstructionsResponse();
  }

  @override
  Future<ExamStartResponse> startExam(int examId) async {
    return startToReturn ?? const ExamStartResponse();
  }

  @override
  Future<ActiveExamSessionResponse> getActiveSession(int examId) async {
    return sessionToReturn ?? const ActiveExamSessionResponse();
  }

  @override
  Future<SaveAnswerResponse> saveAnswer({
    required int examId,
    required int questionId,
    required dynamic answer,
  }) async {
    return saveAnswerToReturn ??
        SaveAnswerResponse(
          success: true,
          questionId: questionId,
          userAnswer: [answer.toString()],
          isSaved: true,
        );
  }

  @override
  Future<ExamSubmitResponse> submitExam({
    required int examId,
    required Map<String, dynamic> answers,
    required int totalDuration,
  }) async {
    return submitToReturn ?? const ExamSubmitResponse();
  }

  @override
  Future<ExamLeaderboardResponse> getExamLeaderboard(int examId) async {
    return leaderboardToReturn ?? const ExamLeaderboardResponse();
  }

  @override
  Future<UserExamsV1Response> getUserExams({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  }) async {
    return UserExamsV1Response(
      success: true,
      items: [],
      meta: UserExamV1Meta(
        currentPage: 1,
        lastPage: 1,
        perPage: perPage,
        total: 0,
        from: 0,
        to: 0,
        hasMore: false,
      ),
    );
  }
}

void main() {
  group('17 V1 Exam Lifecycle Models Tests', () {
    test('1. ExamInstructionsResponse parses exact Step 1 prompt payload', () {
      final json = {
        "success": true,
        "message": "Exam instructions retrieved successfully.",
        "data": {
          "exam": {
            "id": 1,
            "title": "46th BCS Special Model Test 01",
            "duration": 60,
            "total_questions": 100,
            "positive_mark": 1.0,
            "negative_mark": 0.5,
            "pass_mark": 50,
            "exam_type": "paid",
            "exam_mode": "exam",
            "is_active": true
          },
          "instructions": [
            "প্রতিটি সঠিক উত্তরের জন্য ১.০০ নম্বর বরাদ্দ থাকবে।",
            "প্রতিটি ভুল উত্তরের জন্য ০.৫০ নম্বর কাটা যাবে।",
            "পাস মার্ক: ৫০.০০ নম্বর।",
            "নির্ধারিত ৬০ মিনিটের মধ্যে পরীক্ষা সম্পন্ন করতে হবে।",
            "সময় শেষ হলে স্বয়ংক্রিয়ভাবে উত্তরপত্র সাবমিট হয়ে যাবে।"
          ],
          "user_eligibility": {
            "can_take_exam": true,
            "reason": null,
            "is_logged_in": true,
            "requires_package": false,
            "has_active_session": false,
            "active_session_id": null
          },
          "webview_urls": {
            "start": "https://lokkha.com/api/v1/exams/1/webview/start",
            "read": "https://lokkha.com/api/v1/exams/1/webview/read"
          }
        }
      };

      final response = ExamInstructionsResponse.fromJson(json);

      expect(response.success, true);
      expect(response.message, "Exam instructions retrieved successfully.");
      expect(response.data.exam.id, 1);
      expect(response.data.exam.title, "46th BCS Special Model Test 01");
      expect(response.data.exam.duration, 60);
      expect(response.data.exam.totalQuestions, 100);
      expect(response.data.exam.positiveMark, 1.0);
      expect(response.data.exam.negativeMark, 0.5);
      expect(response.data.exam.passMark, 50.0);
      expect(response.data.exam.examType, "paid");
      expect(response.data.exam.isActive, true);

      expect(response.data.instructions.length, 5);
      expect(response.data.instructions.first,
          "প্রতিটি সঠিক উত্তরের জন্য ১.০০ নম্বর বরাদ্দ থাকবে।");

      expect(response.data.eligibility.canTakeExam, true);
      expect(response.data.eligibility.hasActiveSession, false);
      expect(response.data.eligibility.requiresPackage, false);

      expect(response.data.webviewUrls.start,
          "https://lokkha.com/api/v1/exams/1/webview/start");
      expect(response.data.webviewUrls.read,
          "https://lokkha.com/api/v1/exams/1/webview/read");
    });

    test('2. ExamStartResponse parses exact Step 2 prompt payload', () {
      final json = {
        "success": true,
        "message": "Exam session started successfully.",
        "data": {
          "session": {
            "result_id": 482,
            "exam_id": 1,
            "status": "pending",
            "started_at": "2026-10-19T08:30:00Z",
            "total_seconds": 3600,
            "remaining_seconds": 3585,
            "elapsed_seconds": 15,
            "is_resumed": false
          },
          "questions": [
            {
              "id": 105,
              "title": "চর্যাপদ কোন ছন্দে রচিত?",
              "question_image": null,
              "options": [
                {"key": "0", "value": "মাত্রাবৃত্ত"},
                {"key": "1", "value": "অক্ষরবৃত্ত"},
                {"key": "2", "value": "স্বরবৃত্ত"},
                {"key": "3", "value": "পয়ার"}
              ],
              "subject": "বাংলা সাহিত্য"
            }
          ],
          "webview_url":
              "https://lokkha.com/api/v1/exams/1/webview/start?token=eyJhbGciOi..."
        }
      };

      final response = ExamStartResponse.fromJson(json);

      expect(response.success, true);
      expect(response.session.resultId, 482);
      expect(response.session.examId, 1);
      expect(response.session.remainingSeconds, 3585);
      expect(response.session.elapsedSeconds, 15);
      expect(response.session.isResumed, false);

      expect(response.questions.length, 1);
      final q = response.questions.first;
      expect(q.id, 105);
      expect(q.title, "চর্যাপদ কোন ছন্দে রচিত?");
      expect(q.subject, "বাংলা সাহিত্য");
      expect(q.options.length, 4);
      expect(q.options[0].key, "0");
      expect(q.options[0].value, "মাত্রাবৃত্ত");

      expect(response.webviewUrl,
          "https://lokkha.com/api/v1/exams/1/webview/start?token=eyJhbGciOi...");
    });

    test('3. ActiveExamSessionResponse parses exact Step 2 recover payload', () {
      final json = {
        "success": true,
        "message": "Active exam session retrieved.",
        "data": {
          "has_active_session": true,
          "session": {
            "result_id": 482,
            "exam_id": 1,
            "status": "pending",
            "started_at": "2026-10-19T08:30:00Z",
            "total_seconds": 3600,
            "remaining_seconds": 3120,
            "elapsed_seconds": 480
          },
          "saved_answers": {
            "105": ["0"],
            "106": ["2"]
          }
        }
      };

      final response = ActiveExamSessionResponse.fromJson(json);

      expect(response.success, true);
      expect(response.hasActiveSession, true);
      expect(response.session?.resultId, 482);
      expect(response.session?.remainingSeconds, 3120);
      expect(response.savedAnswers["105"], ["0"]);
      expect(response.savedAnswers["106"], ["2"]);
    });

    test('4. SaveAnswerResponse parses exact Step 3 autosave payload', () {
      final json = {
        "success": true,
        "message": "Answer saved successfully.",
        "data": {
          "question_id": 105,
          "user_answer": ["0"],
          "is_saved": true
        }
      };

      final response = SaveAnswerResponse.fromJson(json);

      expect(response.success, true);
      expect(response.questionId, 105);
      expect(response.userAnswer, ["0"]);
      expect(response.isSaved, true);
    });

    test('5. ExamSubmitResponse parses exact Step 4 submit payload', () {
      final json = {
        "success": true,
        "message": "Exam submitted successfully.",
        "data": {
          "result_id": 482,
          "exam_id": 1,
          "score": 74.5,
          "total_questions": 100,
          "correct_answers": 78,
          "incorrect_answers": 7,
          "unanswered": 15,
          "score_percent": 74.5,
          "status": "Passed",
          "rank": 4,
          "total_candidates": 128,
          "duration_seconds": 1845,
          "webview_result_url":
              "https://lokkha.com/api/v1/exams/1/webview/result/482?token=eyJhbGciOi..."
        }
      };

      final response = ExamSubmitResponse.fromJson(json);

      expect(response.success, true);
      expect(response.data.resultId, 482);
      expect(response.data.examId, 1);
      expect(response.data.score, 74.5);
      expect(response.data.totalQuestions, 100);
      expect(response.data.correctAnswers, 78);
      expect(response.data.incorrectAnswers, 7);
      expect(response.data.unanswered, 15);
      expect(response.data.scorePercent, 74.5);
      expect(response.data.status, "Passed");
      expect(response.data.rank, 4);
      expect(response.data.totalCandidates, 128);
      expect(response.data.durationSeconds, 1845);
      expect(response.data.webviewResultUrl,
          "https://lokkha.com/api/v1/exams/1/webview/result/482?token=eyJhbGciOi...");
    });

    test('6. ExamLeaderboardResponse parses merit candidates list', () {
      final json = {
        "success": true,
        "message": "Leaderboard retrieved",
        "data": [
          {
            "rank": 1,
            "user_id": 12,
            "name": "Sadia Islam",
            "score": 92.5,
            "duration_seconds": 1500
          },
          {
            "rank": 2,
            "user_id": 14,
            "name": "Tanvir Hasan",
            "score": 88.0,
            "duration_seconds": 1620
          }
        ]
      };

      final response = ExamLeaderboardResponse.fromJson(json);

      expect(response.success, true);
      expect(response.candidates.length, 2);
      expect(response.candidates.first.rank, 1);
      expect(response.candidates.first.name, "Sadia Islam");
      expect(response.candidates.first.score, 92.5);
    });
  });

  group('17 Exam API Endpoints Verification', () {
    test('Verifies all 17 endpoint definitions and path constructors', () {
      expect(Endpoints.v1Exams, '/api/v1/exams');
      expect(Endpoints.v1ExamCategories, '/api/v1/exams/categories');
      expect(Endpoints.v1ExamCategory(5), '/api/v1/exams/categories/5');
      expect(Endpoints.v1ExamDetail(1), '/api/v1/exams/1');
      expect(Endpoints.v1ExamInstructions(1), '/api/v1/exams/1/instructions');
      expect(Endpoints.v1ExamStart(1), '/api/v1/exams/1/start');
      expect(Endpoints.v1ExamSession(1), '/api/v1/exams/1/session');
      expect(Endpoints.v1ExamSaveAnswer(1), '/api/v1/exams/1/save-answer');
      expect(Endpoints.v1ExamSubmit(1), '/api/v1/exams/1/submit');
      expect(Endpoints.v1ExamResult(1, 482), '/api/v1/exams/1/result/482');
      expect(Endpoints.v1ExamLeaderboard(1), '/api/v1/exams/1/leaderboard');
      expect(Endpoints.v1ExamRead(1), '/api/v1/exams/1/read');

      final webStart = Endpoints.v1ExamWebviewStart(1, token: 'jwt123');
      expect(webStart.contains('/api/v1/exams/1/webview/start?token=jwt123'), true);

      final webResult = Endpoints.v1ExamWebviewResult(1, 482, token: 'jwt123');
      expect(webResult.contains('/api/v1/exams/1/webview/result/482?token=jwt123'), true);

      final webRead = Endpoints.v1ExamWebviewRead(1, token: 'jwt123');
      expect(webRead.contains('/api/v1/exams/1/webview/read?token=jwt123'), true);

      expect(Endpoints.v1UserExams, '/api/v1/user/exams');
      expect(Endpoints.v1UserExamDetail(1), '/api/v1/user/exams/1');
    });
  });

  group('ExamTakingNotifier Lifecycle State Management', () {
    test('Notifier loads instructions and updates state', () async {
      final mockRepo = MockExamLifecycleRepository();
      mockRepo.instructionsToReturn = const ExamInstructionsResponse(
        success: true,
        message: "OK",
        data: ExamInstructionsData(
          exam: ExamMetaInfo(
            id: 1,
            title: "BCS Model Test",
            duration: 60,
            totalQuestions: 100,
          ),
          instructions: ["Do not cheat"],
          eligibility: UserEligibility(canTakeExam: true),
          webviewUrls: ExamWebViewUrls(
            start: "https://lokkha.com/start",
            read: "https://lokkha.com/read",
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          examRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(examTakingNotifierProvider.notifier);
      final instructions = await notifier.loadInstructions(1);

      expect(instructions, isNotNull);
      expect(instructions?.exam.title, "BCS Model Test");
      expect(instructions?.instructions.first, "Do not cheat");
      expect(instructions?.eligibility.canTakeExam, true);
    });

    test('Notifier saves answer and submits exam successfully', () async {
      final mockRepo = MockExamLifecycleRepository();
      mockRepo.submitToReturn = const ExamSubmitResponse(
        success: true,
        message: "Submitted",
        data: ExamSubmitResultData(
          resultId: 482,
          examId: 1,
          score: 80.0,
          status: "Passed",
          rank: 2,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          examRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(examTakingNotifierProvider.notifier);

      final isSaved = await notifier.saveAnswer(
        examId: 1,
        questionId: 105,
        answer: "0",
      );
      expect(isSaved, true);

      final result = await notifier.submitExam(
        examId: 1,
        answers: {"105": "0"},
        totalDuration: 1200,
      );

      expect(result, isNotNull);
      expect(result?.score, 80.0);
      expect(result?.status, "Passed");
      expect(result?.rank, 2);
    });
  });
}
