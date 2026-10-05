import 'package:dio/dio.dart';

import '../core/services/network_service.dart';
import '../models/user_model.dart';
import 'api_client.dart';

/// Authentication Service
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // ═══════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _apiClient.saveToken(data['access_token']);
        if (data['refresh_token'] != null) {
          await _apiClient.saveRefreshToken(data['refresh_token']);
        }
        return AuthResult.success(
          user: User.fromJson(data['user']),
          token: data['access_token'],
        );
      }

      return AuthResult.failure(
        message: response.data['detail'] ?? 'Login failed',
      );
    } on DioException catch (e) {
      return AuthResult.failure(message: _handleError(e));
    }
  }

  // ═══════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? address,
    String? nationality,
    String? bio,
    List<String>? languages,
    String? specialization,
    int? experience,
    double? dailyRate,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phone,
        'role': role,
      };

      // Add optional fields based on role
      if (address != null) data['address'] = address;
      if (nationality != null) data['nationality'] = nationality;
      if (bio != null) data['bio'] = bio;
      if (languages != null) data['languages'] = languages;
      if (specialization != null) data['specialization'] = specialization;
      if (experience != null) data['experience'] = experience;
      if (dailyRate != null) data['daily_rate'] = dailyRate;

      final response = await _apiClient.dio.post(
        '/api/v1/auth/register',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        await _apiClient.saveToken(responseData['access_token']);
        if (responseData['refresh_token'] != null) {
          await _apiClient.saveRefreshToken(responseData['refresh_token']);
        }
        return AuthResult.success(
          user: User.fromJson(responseData['user']),
          token: responseData['access_token'],
        );
      }

      return AuthResult.failure(
        message: response.data['detail'] ?? 'Registration failed',
      );
    } on DioException catch (e) {
      return AuthResult.failure(message: _handleError(e));
    }
  }

  // ═══════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ═══════════════════════════════════════════════════
  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return AuthResult.success(
          message: response.data['detail'] ?? 'Password reset email sent',
        );
      }

      return AuthResult.failure(
        message: response.data['detail'] ?? 'Failed to send reset email',
      );
    } on DioException catch (e) {
      return AuthResult.failure(message: _handleError(e));
    }
  }

  // ═══════════════════════════════════════════════════
  // GET PROFILE
  // ═══════════════════════════════════════════════════
  Future<AuthResult> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/auth/profile');

      if (response.statusCode == 200) {
        return AuthResult.success(user: User.fromJson(response.data));
      }

      return AuthResult.failure(message: 'Failed to load profile');
    } on DioException catch (e) {
      return AuthResult.failure(message: _handleError(e));
    }
  }

  // ═══════════════════════════════════════════════════
  // UPDATE PROFILE
  // ═══════════════════════════════════════════════════
  Future<AuthResult> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/auth/profile',
        data: data,
      );

      if (response.statusCode == 200) {
        return AuthResult.success(user: User.fromJson(response.data));
      }

      return AuthResult.failure(
        message: response.data['detail'] ?? 'Failed to update profile',
      );
    } on DioException catch (e) {
      return AuthResult.failure(message: _handleError(e));
    }
  }

  // ═══════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════
  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  // ═══════════════════════════════════════════════════
  // CHECK AUTH STATUS
  // ═══════════════════════════════════════════════════
  Future<bool> isAuthenticated() async {
    return await _apiClient.hasToken();
  }

  // ═══════════════════════════════════════════════════
  // ERROR HANDLING
  // ═══════════════════════════════════════════════════
  String _handleError(DioException e) {
    // Check for our custom NetworkException first (no connectivity)
    if (e.error is NetworkException) {
      return e.error.toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.connectionError:
        // Likely 'Connection refused' — backend not running or wrong host
        final addr = e.requestOptions.uri;
        if (e.error.toString().contains('Connection refused')) {
          return 'Cannot reach server at $addr.\n'
              'Make sure the backend is running.\n'
              'On a physical Android device, run: adb reverse tcp:8000 tcp:8000';
        }
        return 'Connection error. Please check your network.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final detail = e.response?.data?['detail'];
        if (statusCode == 401) return 'Invalid email or password';
        if (statusCode == 404) return 'Account not found';
        if (statusCode == 422) return detail ?? 'Invalid input data';
        if (statusCode == 409) return 'Email already registered';
        return detail ?? 'Server error ($statusCode)';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error. Please check your connection.';
    }
  }
}

/// Auth Result class
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? token;
  final String? message;

  AuthResult.success({this.user, this.token, this.message}) : isSuccess = true;

  AuthResult.failure({required this.message})
    : isSuccess = false,
      user = null,
      token = null;
}
