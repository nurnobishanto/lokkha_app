import '../../data/models/about_model.dart';
import '../repositories/about_repository.dart';

class GetAboutContentUseCase {
  final AboutRepository repository;

  GetAboutContentUseCase(this.repository);

  Future<AboutDataModel> call() async {
    return await repository.getAboutData();
  }
}
