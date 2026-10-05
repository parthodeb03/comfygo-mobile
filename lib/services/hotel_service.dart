import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/hotel_model.dart';
import 'api_client.dart';

/// Hotel Service
class HotelService {
  final ApiClient _apiClient;

  HotelService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // GET ALL HOTELS
  // ═══════════════════════════════════════════════════
  Future<List<Hotel>> getHotels({
    String? search,
    String? division,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (division != null) queryParams['division'] = division;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;

      final response = await _apiClient.dio.get(
        '/api/v1/hotels',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Hotel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching hotels: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET HOTEL BY ID
  // ═══════════════════════════════════════════════════
  Future<Hotel?> getHotelById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/hotels/$id');

      if (response.statusCode == 200) {
        return Hotel.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching hotel: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // CREATE HOTEL (Hotel Manager)
  // ═══════════════════════════════════════════════════
  Future<Hotel?> createHotel(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/v1/hotels', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Hotel.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error creating hotel: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // UPDATE HOTEL
  // ═══════════════════════════════════════════════════
  Future<Hotel?> updateHotel(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/hotels/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return Hotel.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error updating hotel: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // DELETE HOTEL
  // ═══════════════════════════════════════════════════
  Future<bool> deleteHotel(int id) async {
    try {
      final response = await _apiClient.dio.delete('/api/v1/hotels/$id');
      return response.statusCode == 200;
    } on DioException catch (e) {
      AppLogger.error(
        'Error deleting hotel: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return false;
    }
  }
}
