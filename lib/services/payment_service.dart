import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/payment_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Payment Service
class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // GET USER PAYMENTS
  // ═══════════════════════════════════════════════════
  Future<List<Payment>> getMyPayments({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/payments',
        queryParameters: {'page': page, 'limit': limit},
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
        'Error fetching payments: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════════════
  // GET PAYMENT BY ID
  // ═══════════════════════════════════════════════════
  Future<Payment?> getPaymentById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/payments/$id');

      if (response.statusCode == 200) {
        return Payment.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching payment: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // CREATE PAYMENT - Card
  // ═══════════════════════════════════════════════════
  Future<Payment?> createCardPayment({
    required int bookingId,
    required double amount,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/payments',
        data: {
          'booking_id': bookingId,
          'amount': amount,
          'method': 'card',
          'card_number': cardNumber,
          'expiry_date': expiryDate,
          'cvv': cvv,
          'cardholder_name': cardholderName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Payment.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error creating card payment: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // CREATE PAYMENT - Mobile wallet (bKash / Nagad)
  // ═══════════════════════════════════════════════════
  Future<Payment?> createWalletPayment({
    required int bookingId,
    required double amount,
    required String method, // 'bkash' | 'nagad'
    required String walletNumber,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/payments',
        data: {
          'booking_id': bookingId,
          'amount': amount,
          'method': method,
          'wallet_number': walletNumber,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Payment.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error creating wallet payment: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // CREATE PAYMENT - Cash
  // ═══════════════════════════════════════════════════
  Future<Payment?> createCashPayment({
    required int bookingId,
    required double amount,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/payments',
        data: {
          'booking_id': bookingId,
          'amount': amount,
          'method': 'cash',
          'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Payment.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error creating cash payment: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // CONFIRM CASH PAYMENT (Admin/Manager)
  // ═══════════════════════════════════════════════════
  Future<Payment?> confirmPayment(int id) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/payments/$id/confirm');

      if (response.statusCode == 200) {
        return Payment.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error confirming payment: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // REFUND PAYMENT (Admin)
  // ═══════════════════════════════════════════════════
  Future<Payment?> refundPayment(int id, {String? reason}) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/payments/$id/refund',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return Payment.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error refunding payment: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }
}
