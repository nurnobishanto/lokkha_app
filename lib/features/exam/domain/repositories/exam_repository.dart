import '../../data/datasources/exam_remote_data_source.dart';
import '../../data/models/user_exam_v1_model.dart';
import '../../data/repositories/exam_repository_impl.dart';

abstract class ExamRepository {
  factory ExamRepository() =>
      ExamRepositoryImpl(remoteDataSource: ExamRemoteDataSourceImpl());

  Future<UserExamsV1Response> getUserExams({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  });
}
