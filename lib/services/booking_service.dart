import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/booking_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Booking Service
class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // GET USER BOOKINGS
  // ═══════════════════════════════════════════════════
  Future<List<Booking>> getMyBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.dio.get(
        '/api/v1/bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Booking.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching bookings: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET BOOKING BY ID
  // ═══════════════════════════════════════════════════
  Future<Booking?> getBookingById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/bookings/$id');

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching booking: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // CREATE BOOKING
  // ═══════════════════════════════════════════════════
  Future<Booking?> createBooking({
    required String type,
    required int itemId,
    required DateTime checkIn,
    DateTime? checkOut,
    required int guests,
    String? notes,
  }) async {
    try {
      final data = {
        'type': type,
        'item_id': itemId,
        'check_in': checkIn.toIso8601String(),
        'guests': guests,
      };
      if (checkOut != null) data['check_out'] = checkOut.toIso8601String();
      if (notes != null) data['notes'] = notes;

      final response = await _apiClient.dio.post(
        '/api/v1/bookings',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Booking.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error creating booking: ${e.message}',
        e.error,
        e.stackTrace,
      );
      // Surface the backend's reason (validation, availability, …)
      throw apiExceptionFrom(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // CANCEL BOOKING
  // ═══════════════════════════════════════════════════
  Future<Booking?> cancelBooking(int id) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/bookings/$id/cancel');

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error cancelling booking: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // UPDATE BOOKING STATUS (Manager/Guide)
  // ═══════════════════════════════════════════════════
  Future<Booking?> updateBookingStatus(int id, String status) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/bookings/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error updating booking status: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }
}
