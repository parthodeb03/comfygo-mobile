import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/package_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Package Service
class PackageService {
  final ApiClient _apiClient;

  PackageService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // GET ALL PACKAGES
  // ═══════════════════════════════════════════════════
  Future<List<Package>> getPackages() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/packages');

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Package.fromJson(json))
            .toList();
      }

      return Package.predefinedPackages;
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching packages: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return Package.predefinedPackages;
    }
  }

  // ═══════════════════════════════════════════════════
  // GET USER'S CURRENT PACKAGE
  // ═══════════════════════════════════════════════════
  Future<UserPackage?> getMyPackage() async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/user-packages/current',
      );

      if (response.statusCode == 200) {
        return UserPackage.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching user package: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  // SUBSCRIBE TO PACKAGE
  // ═══════════════════════════════════════════════════
  Future<UserPackage?> subscribeToPackage({
    required int packageId,
    required String paymentMethod,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
  }) async {
    try {
      final data = {'package_id': packageId, 'payment_method': paymentMethod};

      if (cardNumber != null) data['card_number'] = cardNumber;
      if (expiryDate != null) data['expiry_date'] = expiryDate;
      if (cvv != null) data['cvv'] = cvv;

      final response = await _apiClient.dio.post(
        '/api/v1/user-packages',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserPackage.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error subscribing to package: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // UPGRADE PACKAGE
  // ═══════════════════════════════════════════════════
  Future<UserPackage?> upgradePackage({
    required int newPackageId,
    required String paymentMethod,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
  }) async {
    try {
      final data = {
        'package_id': newPackageId,
        'payment_method': paymentMethod,
      };

      if (cardNumber != null) data['card_number'] = cardNumber;
      if (expiryDate != null) data['expiry_date'] = expiryDate;
      if (cvv != null) data['cvv'] = cvv;

      final response = await _apiClient.dio.put(
        '/api/v1/user-packages/upgrade',
        data: data,
      );

      if (response.statusCode == 200) {
        return UserPackage.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error upgrading package: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // CANCEL PACKAGE
  // ═══════════════════════════════════════════════════
  Future<bool> cancelPackage() async {
    try {
      final response = await _apiClient.dio.put('/api/v1/user-packages/cancel');
      return response.statusCode == 200;
    } on DioException catch (e) {
      AppLogger.error(
        'Error cancelling package: ${e.message}',
        e.error,
        e.stackTrace,
      );
      return false;
    }
  }
}
