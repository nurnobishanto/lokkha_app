import '../../domain/repositories/about_repository.dart';
import '../datasources/about_remote_data_source.dart';
import '../models/about_model.dart';

class AboutRepositoryImpl implements AboutRepository {
  final AboutRemoteDataSource remoteDataSource;

  AboutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AboutDataModel> getAboutData() async {
    return await remoteDataSource.getAboutData();
  }
}
