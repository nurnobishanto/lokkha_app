import 'package:lokkha/core/errors/exceptions.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/network/rest_client.dart';
import '../models/about_model.dart';

abstract class AboutRemoteDataSource {
  Future<AboutDataModel> getAboutData();
}

class AboutRemoteDataSourceImpl implements AboutRemoteDataSource {
  final RestClient client;

  AboutRemoteDataSourceImpl({required this.client});

  @override
  Future<AboutDataModel> getAboutData() async {
    try {
      final response = await client.get<Map<String, dynamic>>(Endpoints.about);
      final data = response.data;
      if (data == null) {
        throw const ServerException('No data received from about endpoint');
      }

      final parsed = AboutResponseModel.fromJson(data);
      if (parsed.data == null) {
        throw ServerException(parsed.message.isNotEmpty ? parsed.message : 'Failed to parse about content');
      }

      return parsed.data!;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
