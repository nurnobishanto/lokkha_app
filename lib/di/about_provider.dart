import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/about/data/datasources/about_remote_data_source.dart';
import 'package:lokkha/features/about/data/repositories/about_repository_impl.dart';
import 'package:lokkha/features/about/domain/repositories/about_repository.dart';
import 'package:lokkha/features/about/domain/usecases/get_about_content_usecase.dart';

/// About Remote Data Source Provider
final aboutRemoteDataSourceProvider = Provider<AboutRemoteDataSource>((ref) {
  final client = ref.watch(restClientProvider);
  return AboutRemoteDataSourceImpl(client: client);
});

/// About Repository Provider
final aboutRepositoryProvider = Provider<AboutRepository>((ref) {
  final remoteDataSource = ref.watch(aboutRemoteDataSourceProvider);
  return AboutRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Get About Content Use Case Provider
final getAboutContentUseCaseProvider = Provider<GetAboutContentUseCase>((ref) {
  final repository = ref.watch(aboutRepositoryProvider);
  return GetAboutContentUseCase(repository);
});
