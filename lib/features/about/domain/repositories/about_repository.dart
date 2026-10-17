import '../../data/models/about_model.dart';

abstract class AboutRepository {
  Future<AboutDataModel> getAboutData();
}
