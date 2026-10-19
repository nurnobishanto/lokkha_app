import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/contest/data/datasources/contest_remote_data_source.dart';
import 'package:lokkha/features/contest/data/repositories/contest_repository_impl.dart';
import 'package:lokkha/features/contest/domain/repositories/contest_repository.dart';

export 'package:lokkha/features/contest/domain/repositories/contest_repository.dart';

/// Contest Remote Data Source Provider with singleton client injection
final contestRemoteDataSourceProvider =
    Provider<ContestRemoteDataSource>((ref) {
  final client = ref.watch(restClientProvider);
  return ContestRemoteDataSourceImpl(client: client);
});

/// Contest Repository Provider
final contestRepositoryProvider = Provider<ContestRepository>((ref) {
  final remoteDataSource = ref.watch(contestRemoteDataSourceProvider);
  return ContestRepositoryImpl(remoteDataSource: remoteDataSource);
});
