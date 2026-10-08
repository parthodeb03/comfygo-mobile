import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// DB-backed favorites service.
class FavoriteService {
  final ApiClient _apiClient;

  FavoriteService(this._apiClient);

  Future<List<Favorite>> getFavorites() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/favorites');
      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Favorite.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching favorites: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }

  /// Add or re-add a favorite (idempotent).
  Future<Favorite?> toggleFavorite(String itemType, int itemId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/favorites',
        data: {'item_type': itemType, 'item_id': itemId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Favorite.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error toggling favorite: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }

  Future<void> removeFavorite(String itemType, int itemId) async {
    try {
      await _apiClient.dio.delete(
        '/api/v1/favorites/$itemType/$itemId',
      );
    } on DioException catch (e) {
      AppLogger.error(
        'Error removing favorite: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }
}
