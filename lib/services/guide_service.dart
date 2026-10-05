import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/guide_model.dart';
import 'api_client.dart';

/// Guide Service
class GuideService {
  final ApiClient _apiClient;

  GuideService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // GET ALL GUIDES
  // ═══════════════════════════════════════════════════
  Future<List<Guide>> getGuides({
    String? search,
    String? specialization,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (specialization != null) {
        queryParams['specialization'] = specialization;
      }
      if (location != null) queryParams['location'] = location;

      final response = await _apiClient.dio.get(
        '/api/v1/guides',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Guide.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching guides: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET GUIDE BY ID
  // ═══════════════════════════════════════════════════
  Future<Guide?> getGuideById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/guides/$id');

      if (response.statusCode == 200) {
        return Guide.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching guide: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // CREATE GUIDE (Guide signup)
  // ═══════════════════════════════════════════════════
  Future<Guide?> createGuide(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/v1/guides', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Guide.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error creating guide: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // UPDATE GUIDE
  // ═══════════════════════════════════════════════════
  Future<Guide?> updateGuide(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/guides/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return Guide.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error updating guide: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }
}
