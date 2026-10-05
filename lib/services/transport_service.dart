import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/transport_model.dart';
import 'api_client.dart';

/// Transport Service
class TransportService {
  final ApiClient _apiClient;

  TransportService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // GET ALL TRANSPORTS
  // ═══════════════════════════════════════════════════
  Future<List<Transport>> getTransports({
    String? search,
    String? type,
    String? fromLocation,
    String? toLocation,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (type != null) queryParams['type'] = type;
      if (fromLocation != null) queryParams['from_location'] = fromLocation;
      if (toLocation != null) queryParams['to_location'] = toLocation;

      final response = await _apiClient.dio.get(
        '/api/v1/transports',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Transport.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching transports: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET TRANSPORT BY ID
  // ═══════════════════════════════════════════════════
  Future<Transport?> getTransportById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/transports/$id');

      if (response.statusCode == 200) {
        return Transport.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching transport: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // CREATE TRANSPORT
  // ═══════════════════════════════════════════════════
  Future<Transport?> createTransport(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/transports',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Transport.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error creating transport: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // UPDATE TRANSPORT
  // ═══════════════════════════════════════════════════
  Future<Transport?> updateTransport(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/transports/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return Transport.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error updating transport: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }
}
