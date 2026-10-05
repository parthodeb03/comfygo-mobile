import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/destination_model.dart';
import 'api_client.dart';

/// Destination Service
class DestinationService {
  final ApiClient _apiClient;

  DestinationService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // GET ALL DESTINATIONS
  // ═══════════════════════════════════════════════════
  Future<List<Destination>> getDestinations({
    String? search,
    String? division,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (division != null && division.isNotEmpty) {
        queryParams['division'] = division;
      }

      final response = await _apiClient.dio.get(
        '/api/v1/destinations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Destination.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching destinations: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET DESTINATION BY ID
  // ═══════════════════════════════════════════════════
  Future<Destination?> getDestinationById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/destinations/$id');

      if (response.statusCode == 200) {
        return Destination.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching destination: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // GET FEATURED DESTINATIONS
  // ═══════════════════════════════════════════════════
  Future<List<Destination>> getFeaturedDestinations() async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/destinations/featured',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Destination.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching featured destinations: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET DESTINATIONS BY DIVISION
  // ═══════════════════════════════════════════════════
  Future<List<Destination>> getDestinationsByDivision(String division) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/destinations',
        queryParameters: {'division': division},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Destination.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching destinations by division: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }
}
