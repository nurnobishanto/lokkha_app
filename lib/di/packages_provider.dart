import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:lokkha/features/packages/data/repositories/packages_repository_impl.dart';
import 'package:lokkha/features/packages/domain/repositories/packages_repository.dart';

export 'package:lokkha/features/packages/domain/repositories/packages_repository.dart';

/// Packages Remote Data Source Provider with singleton client injection
final packagesRemoteDataSourceProvider =
    Provider<PackagesRemoteDataSource>((ref) {
  final client = ref.watch(restClientProvider);
  return PackagesRemoteDataSourceImpl(client: client);
});

/// Packages Repository Provider
final packagesRepositoryProvider = Provider<PackagesRepository>((ref) {
  final remoteDataSource = ref.watch(packagesRemoteDataSourceProvider);
  return PackagesRepositoryImpl(remoteDataSource: remoteDataSource);
});
