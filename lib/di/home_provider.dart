import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/home/data/datasources/home_remote_data_source.dart';
import 'package:lokkha/features/home/data/repositories/home_repository_impl.dart';
import 'package:lokkha/features/home/domain/repositories/home_repository.dart';
import 'package:lokkha/features/home/domain/usecases/get_home_feed_usecase.dart';

/// Home Remote Data Source Provider
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final client = ref.watch(restClientProvider);
  return HomeRemoteDataSourceImpl(client: client);
});

/// Home Repository Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Get Home Feed Use Case Provider
final getHomeFeedUseCaseProvider = Provider<GetHomeFeedUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetHomeFeedUseCase(repository);
});
