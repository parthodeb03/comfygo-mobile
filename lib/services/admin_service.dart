import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../models/hotel_model.dart';
import '../models/package_model.dart';
import 'api_client.dart';

/// Admin Service
class AdminService {
  final ApiClient _apiClient;

  AdminService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // ADMIN LOGIN
  // ═══════════════════════════════════════════════════
  Future<AdminLoginResult> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/admin/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _apiClient.saveToken(data['access_token']);
        // Persist the refresh token so the session survives app restarts
        if (data['refresh_token'] != null) {
          await _apiClient.saveRefreshToken(data['refresh_token']);
        }
        return AdminLoginResult.success(
          user: User.fromJson(data['user']),
          token: data['access_token'],
        );
      }

      return AdminLoginResult.failure(
        message: response.data['detail'] ?? 'Admin login failed',
      );
    } on DioException catch (e) {
      return AdminLoginResult.failure(message: _handleError(e));
    }
  }

  // ═══════════════════════════════════════════════════
  // GET ALL USERS
  // ═══════════════════════════════════════════════════
  Future<List<User>> getUsers({
    String? search,
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (role != null) queryParams['role'] = role;

      final response = await _apiClient.dio.get(
        '/api/v1/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching users: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET ALL BOOKINGS
  // ═══════════════════════════════════════════════════
  Future<List<Booking>> getAllBookings({
    String? status,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final response = await _apiClient.dio.get(
        '/api/v1/admin/bookings',
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
        'Error fetching all bookings: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET ALL PAYMENTS
  // ═══════════════════════════════════════════════════
  Future<List<Payment>> getAllPayments({
    String? status,
    String? method,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) queryParams['status'] = status;
      if (method != null) queryParams['method'] = method;

      final response = await _apiClient.dio.get(
        '/api/v1/admin/payments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Payment.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching all payments: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET ALL LISTINGS (Hotels, Transports, Guides)
  // ═══════════════════════════════════════════════════
  Future<List<Hotel>> getAllListings({
    String? type,
    bool? approved,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (type != null) queryParams['type'] = type;
      if (approved != null) queryParams['approved'] = approved;

      final response = await _apiClient.dio.get(
        '/api/v1/admin/listings',
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
        'Error fetching all listings: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // APPROVE LISTING
  // ═══════════════════════════════════════════════════
  Future<bool> approveListing(int id) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/admin/listings/$id/approve',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      AppLogger.error(
        'Error approving listing: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return false;
    }
  }

  // ═══════════════════════════════════════════════════
  // REMOVE LISTING
  // ═══════════════════════════════════════════════════
  Future<bool> removeListing(int id) async {
    try {
      final response = await _apiClient.dio.delete(
        '/api/v1/admin/listings/$id',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      AppLogger.error(
        'Error removing listing: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return false;
    }
  }

  // ═══════════════════════════════════════════════════
  // VOID PAYMENT
  // ═══════════════════════════════════════════════════
  Future<Payment?> voidPayment(int id, {String? reason}) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/admin/payments/$id/void',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return Payment.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error voiding payment: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // GET DASHBOARD STATS
  // ═══════════════════════════════════════════════════
  Future<List<UserPackage>> getUserPackages({int page = 1, int limit = 100}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/admin/user-packages',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        return (response.data['items'] as List)
            .map((json) => UserPackage.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      AppLogger.error('Error fetching subscriptions: ${e.message}', e.error, e.stackTrace);
      return [];
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/admin/stats');

      if (response.statusCode == 200) {
        return response.data;
      }

      return {};
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching stats: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return {};
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final detail = e.response?.data?['detail'];
        if (statusCode == 401) return 'Invalid admin credentials';
        if (statusCode == 403) return 'Access denied';
        return detail ?? 'Server error ($statusCode)';
      default:
        return 'Network error. Please check your connection.';
    }
  }
}

class AdminLoginResult {
  final bool isSuccess;
  final User? user;
  final String? token;
  final String? message;

  AdminLoginResult.success({this.user, this.token, this.message})
    : isSuccess = true;

  AdminLoginResult.failure({required this.message})
    : isSuccess = false,
      user = null,
      token = null;
}
