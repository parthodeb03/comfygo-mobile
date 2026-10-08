import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/api_constants.dart';
import '../core/services/network_service.dart';
import '../core/utils/app_logger.dart';

/// API Client with JWT authentication, retry, and offline caching
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiClient({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage() {
    if (!kDebugMode && Uri.parse(ApiConstants.baseUrl).scheme != 'https') {
      throw StateError('Release builds require an HTTPS API_BASE_URL.');
    }
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      ConnectivityInterceptor(),
      OfflineCacheInterceptor(),
      RetryInterceptor(dio: _dio),
      _AuthInterceptor(_dio, _storage),
      _LogInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// Check if the backend is reachable
  Future<bool> checkHealth() => checkBackendHealth();

  /// Clear offline cache
  Future<void> clearCache() => OfflineCacheInterceptor.clearCache();

  // ═══════════════════════════════════════════════════
  // TOKEN MANAGEMENT
  // ═══════════════════════════════════════════════════

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

/// Auth Interceptor - adds JWT token to requests
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._dio, this._storage);

  static const _retriedKey = 'auth_token_refreshed';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for auth endpoints
    if (options.path.contains('/auth/')) {
      return handler.next(options);
    }

    final token = await _storage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;

      // Never refresh in response to these — refreshing can't fix them:
      //  * /auth/refresh  → a failing refresh must not trigger itself
      //  * login/register/forgot-password → wrong credentials must fail fast
      final isRefreshCall = path.contains('/auth/refresh');
      final isCredentialCall =
          path.contains('/auth/login') ||
          path.contains('/auth/register') ||
          path.contains('/auth/forgot-password');

      // One refresh per request max — otherwise a retried request that still
      // returns 401 would loop forever (refresh → retry → 401 → refresh …).
      final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

      if (!isRefreshCall && !isCredentialCall && !alreadyRetried) {
        // Try to refresh token
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          try {
            final response = await _dio.post(
              ApiConstants.refreshToken,
              data: {'refresh_token': refreshToken},
            );

            if (response.statusCode == 200) {
              final newToken = response.data['access_token'];
              await _storage.write(key: 'jwt_token', value: newToken);

              // Retry original request exactly once
              err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              err.requestOptions.extra[_retriedKey] = true;
              final retryResponse = await _dio.fetch(err.requestOptions);
              return handler.resolve(retryResponse);
            }
          } catch (e) {
            // Refresh failed, clear tokens
            await _storage.delete(key: 'jwt_token');
            await _storage.delete(key: 'refresh_token');
          }
        }
      }
    }

    return handler.next(err);
  }
}

/// Logging Interceptor
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('[API] ${options.method} ${options.uri}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final fromCache = response.extra['from_cache'] == true;
    AppLogger.info(
      '[API] ${response.statusCode} ${response.requestOptions.uri}'
      '${fromCache ? ' (cached)' : ''}',
    );
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '[API ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}',
      err.error,
      err.stackTrace,
    );
    return handler.next(err);
  }
}
