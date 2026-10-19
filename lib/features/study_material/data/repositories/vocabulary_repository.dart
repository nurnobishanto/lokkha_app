import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/data/models/vocabulary_model.dart';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/shared/models/vocabulary.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepositoryImpl();
});

abstract class VocabularyRepository {
  Future<VocabularyModel> getVocabularies({
    int page = 1,
    int perPage = 30,
    String? alphabet,
    int? typeId,
    int? categoryId,
    String? search,
  });

  Future<List<String>> getAlphabets();

  Future<List<Category>> getCategories();

  Future<List<Category>> getTypes();

  Future<Vocabulary?> getVocabularyDetail(int id);
}

class VocabularyRepositoryImpl implements VocabularyRepository {
  final RestClient _client;

  VocabularyRepositoryImpl({RestClient? client})
      : _client = client ?? RestClient();

  Map<String, String> _buildHeaders() {
    final token = MySharedPref.getUserToken();
    return {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<VocabularyModel> getVocabularies({
    int page = 1,
    int perPage = 30,
    String? alphabet,
    int? typeId,
    int? categoryId,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (alphabet != null && alphabet.trim().isNotEmpty) {
      queryParams['alphabet'] = alphabet.trim().toUpperCase();
    }
    if (typeId != null) {
      queryParams['type_ids[]'] = typeId;
      queryParams['type_id'] = typeId;
    }
    if (categoryId != null) {
      queryParams['category_ids[]'] = categoryId;
      queryParams['category_id'] = categoryId;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    try {
      final response = await _client.get(
        Endpoints.v1Vocabularies,
        queryParameters: queryParams,
        headers: _buildHeaders(),
      );

      if (response.data is Map) {
        final dataMap = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return VocabularyModel.fromJson(dataMap);
      }
    } catch (e) {
      debugPrint('[VocabularyRepository.getVocabularies] Error: $e');
    }

    return VocabularyModel(
      status: false,
      success: false,
      message: 'Failed to retrieve vocabularies.',
      vocabularies: Vocabularies(
        currentPage: page,
        lastPage: 1,
        total: 0,
        data: [],
      ),
    );
  }

  @override
  Future<List<String>> getAlphabets() async {
    try {
      final response = await _client.get(
        Endpoints.v1VocabularyAlphabets,
        headers: _buildHeaders(),
      );

      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => item.toString())
            .toList();
      }
    } catch (e) {
      debugPrint('[VocabularyRepository.getAlphabets] Error: $e');
    }

    // Standard fallback alphabet list if network fails
    return const [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'Y', 'Z'
    ];
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.get(
        Endpoints.v1VocabularyCategories,
        headers: _buildHeaders(),
      );

      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List)
            .whereType<Map>()
            .map((item) => Category.fromJson(
                  item is Map<String, dynamic>
                      ? item
                      : Map<String, dynamic>.from(item),
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('[VocabularyRepository.getCategories] Error: $e');
    }
    return [];
  }

  @override
  Future<List<Category>> getTypes() async {
    try {
      final response = await _client.get(
        Endpoints.v1VocabularyTypes,
        headers: _buildHeaders(),
      );

      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List)
            .whereType<Map>()
            .map((item) => Category.fromJson(
                  item is Map<String, dynamic>
                      ? item
                      : Map<String, dynamic>.from(item),
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('[VocabularyRepository.getTypes] Error: $e');
    }
    return [];
  }

  @override
  Future<Vocabulary?> getVocabularyDetail(int id) async {
    try {
      final response = await _client.get(
        Endpoints.v1VocabularyDetail(id),
        headers: _buildHeaders(),
      );

      if (response.data is Map && response.data['data'] is Map) {
        final dataMap = response.data['data'] is Map<String, dynamic>
            ? response.data['data'] as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data['data'] as Map);
        return Vocabulary.fromJson(dataMap);
      }
    } catch (e) {
      debugPrint('[VocabularyRepository.getVocabularyDetail] Error: $e');
    }
    return null;
  }
}
