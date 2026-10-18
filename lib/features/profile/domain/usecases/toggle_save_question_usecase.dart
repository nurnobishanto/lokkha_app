import '../repositories/profile_repository.dart';

class ToggleSaveQuestionUseCase {
  final ProfileRepository repository;

  ToggleSaveQuestionUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<bool> call(int questionId) {
    return repository.toggleSaveQuestion(questionId);
  }
}
