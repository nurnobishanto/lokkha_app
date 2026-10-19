import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/features/course/data/models/my_course_model.dart'
    show CoursePaginationMeta;
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/shared/models/package.dart';

class _FakeRestClient extends RestClient {
  Map<String, dynamic>? getResponseData;
  Map<String, dynamic>? postResponseData;
  String? lastGetPath;
  Map<String, dynamic>? lastGetQueryParams;
  String? lastPostPath;
  dynamic lastPostData;

  @override
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastGetPath = path;
    lastGetQueryParams = queryParameters;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: getResponseData as T?,
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPostPath = path;
    lastPostData = data;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: postResponseData as T?,
      statusCode: 200,
    );
  }

}

class _MockPackagesRepository implements PackagesRepository {
  PackageDetailResponseModel? packageDetailToReturn;
  PremiumPackageModel? premiumPackagesToReturn;
  Map<String, dynamic>? claimTrialToReturn;
  bool shouldThrow = false;

  @override
  Future<PackageDetailResponseModel?> getPackageDetails(int packageId) async {
    if (shouldThrow) throw Exception('API Error');
    return packageDetailToReturn;
  }

  @override
  Future<PremiumPackageModel?> getPremiumPackages({
    int page = 1,
    int perPage = 15,
    String? search,
    bool? isFeatured,
    bool? isTrial,
    String? sortBy,
  }) async {
    if (shouldThrow) throw Exception('API Error');
    return premiumPackagesToReturn;
  }

  @override
  Future<Map<String, dynamic>?> claimFreeTrial(int packageId) async {
    if (shouldThrow) throw Exception('API Error');
    return claimTrialToReturn;
  }
}

void main() {
  group('Packages Clean Architecture - RemoteDataSource & Repository', () {
    late _FakeRestClient fakeClient;
    late PackagesRemoteDataSource remoteDataSource;
    late PackagesRepository repository;

    setUp(() {
      fakeClient = _FakeRestClient();
      remoteDataSource = PackagesRemoteDataSourceImpl(client: fakeClient);
      repository = PackagesRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test('getPackageDetails parses response and handles repository call', () async {
      fakeClient.getResponseData = {
        'status': true,
        'success': true,
        'package': {
          'id': 10,
          'name': 'বিসিএস প্রিলিমিনারি প্যাকেজ',
          'regular_price': 1000.0,
          'discounted_price': 800.0,
          'duration_days': 90,
        },
      };

      final result = await repository.getPackageDetails(10);
      expect(result, isNotNull);
      expect(result?.success, true);
      expect(result?.package?.id, 10);
      expect(result?.package?.name, 'বিসিএস প্রিলিমিনারি প্যাকেজ');
      expect(fakeClient.lastGetPath, contains('10'));
    });

    test('getPremiumPackages delegates pagination & filters properly', () async {
      fakeClient.getResponseData = {
        'status': true,
        'success': true,
        'data': [
          {
            'id': 1,
            'name': 'প্যাকেজ ১',
            'regular_price': 500.0,
            'discounted_price': 400.0,
            'duration_days': 30,
          }
        ],
        'meta': {
          'current_page': 1,
          'last_page': 2,
          'per_page': 15,
          'total': 25,
        }
      };

      final result = await repository.getPremiumPackages(
        page: 1,
        perPage: 15,
        search: 'বিসিএস',
        isFeatured: true,
      );

      expect(result, isNotNull);
      expect(result?.packages.length, 1);
      expect(result?.packages.first.name, 'প্যাকেজ ১');
      expect(fakeClient.lastGetQueryParams?['search'], 'বিসিএস');
      expect(fakeClient.lastGetQueryParams?['is_featured'], 1);
    });

    test('claimFreeTrial posts package_id and returns server response map', () async {
      fakeClient.postResponseData = {
        'status': true,
        'success': true,
        'message': 'ফ্রি ট্রায়াল চালু হয়েছে',
      };

      final result = await repository.claimFreeTrial(5);
      expect(result, isNotNull);
      expect(result?['status'], true);
      expect(result?['message'], 'ফ্রি ট্রায়াল চালু হয়েছে');
      expect(fakeClient.lastPostData, {'package_id': 5});
    });
  });

  group('PremiumPackagesNotifier with Injected Repository', () {
    test('fetches premium packages and updates state', () async {
      final mockRepo = _MockPackagesRepository();
      mockRepo.premiumPackagesToReturn = PremiumPackageModel(
        success: true,
        packages: [
          Package(id: 1, name: 'প্যাকেজ ১'),
          Package(id: 2, name: 'প্যাকেজ ২'),
        ],
        meta: CoursePaginationMeta(currentPage: 1, lastPage: 2),
      );

      final container = ProviderContainer(
        overrides: [
          premiumPackagesNotifierProvider.overrideWith(
            () => PremiumPackagesNotifier(repository: mockRepo),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(premiumPackagesNotifierProvider.notifier);
      await notifier.fetchPremiumPackages();

      final state = container.read(premiumPackagesNotifierProvider);
      expect(state.isLoading, false);
      expect(state.packages.length, 2);
      expect(state.hasMore, true);
      expect(state.errorMessage, isNull);
    });

    test('loadMore appends packages from next page', () async {
      final mockRepo = _MockPackagesRepository();
      mockRepo.premiumPackagesToReturn = PremiumPackageModel(
        success: true,
        packages: [
          Package(id: 1, name: 'প্যাকেজ ১'),
        ],
        meta: CoursePaginationMeta(currentPage: 1, lastPage: 2),
      );

      final container = ProviderContainer(
        overrides: [
          premiumPackagesNotifierProvider.overrideWith(
            () => PremiumPackagesNotifier(repository: mockRepo),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(premiumPackagesNotifierProvider.notifier);
      await notifier.fetchPremiumPackages();

      // Configure next page
      mockRepo.premiumPackagesToReturn = PremiumPackageModel(
        success: true,
        packages: [
          Package(id: 2, name: 'প্যাকেজ ২'),
        ],
        meta: CoursePaginationMeta(currentPage: 2, lastPage: 2),
      );

      await notifier.loadMore();

      final state = container.read(premiumPackagesNotifierProvider);
      expect(state.isLoadingMore, false);
      expect(state.packages.length, 2);
      expect(state.currentPage, 2);
      expect(state.hasMore, false);
    });

    test('handles repository errors gracefully', () async {
      final mockRepo = _MockPackagesRepository();
      mockRepo.shouldThrow = true;

      final container = ProviderContainer(
        overrides: [
          premiumPackagesNotifierProvider.overrideWith(
            () => PremiumPackagesNotifier(repository: mockRepo),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(premiumPackagesNotifierProvider.notifier);
      await notifier.fetchPremiumPackages();

      final state = container.read(premiumPackagesNotifierProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNotNull);
    });
  });
}
