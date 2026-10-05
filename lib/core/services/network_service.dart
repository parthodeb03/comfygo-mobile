import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../utils/app_logger.dart';

// ═══════════════════════════════════════════════════════════════
// NETWORK EXCEPTION
// ═══════════════════════════════════════════════════════════════

/// Simple exception type for network errors so we can distinguish them
/// from other DioException errors.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}

// ═══════════════════════════════════════════════════════════════
// CONNECTIVITY INTERCEPTOR
// ═══════════════════════════════════════════════════════════════

/// Pre-flight network connectivity check interceptor for Dio.
///
/// Before every HTTP request, verifies the device has an active network
/// connection (WiFi / mobile data). If not, the request is rejected
/// immediately with a clear error — no round-trip to the server needed.
class ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity;

  ConnectivityInterceptor({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final result = await _connectivity.checkConnectivity();
    final hasConnection = result.any((c) => c != ConnectivityResult.none);

    if (!hasConnection) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NetworkException(
            'No internet connection. Please check your network settings.',
          ),
        ),
      );
      return;
    }

    handler.next(options);
  }
}

// ═══════════════════════════════════════════════════════════════
// RETRY INTERCEPTOR
// ═══════════════════════════════════════════════════════════════

/// Automatically retries failed requests for transient errors
/// (timeout, connection refused, server 5xx).
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
  });

  static const _retryKey = 'retry_count';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Never retry health checks or auth endpoints
    final path = err.requestOptions.path;
    if (path.contains('/health') || path.contains('/auth/')) {
      return handler.next(err);
    }

    final retryCount = (err.requestOptions.extra[_retryKey] ?? 0) as int;

    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    final shouldRetry =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.type == DioExceptionType.connectionError) ||
        (err.response?.statusCode ?? 0) >= 500;

    if (!shouldRetry) {
      return handler.next(err);
    }

    AppLogger.info(
      '[RETRY] Attempt ${retryCount + 1}/$maxRetries for ${err.requestOptions.uri}',
    );

    // Exponential backoff
    await Future.delayed(retryDelay * (retryCount + 1));

    // Increment retry count
    err.requestOptions.extra[_retryKey] = retryCount + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// OFFLINE CACHE INTERCEPTOR
// ═══════════════════════════════════════════════════════════════

/// Caches GET responses in SharedPreferences.
/// On failure, returns cached data if available.
class OfflineCacheInterceptor extends Interceptor {
  final Duration maxAge;

  OfflineCacheInterceptor({this.maxAge = const Duration(hours: 1)});

  static const _prefix = 'api_cache_';
  static const _timestampPrefix = 'api_cache_ts_';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    // Check if we have cached data
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _prefix + options.uri.toString();
    final tsKey = _timestampPrefix + options.uri.toString();

    final cached = prefs.getString(cacheKey);
    final cachedTs = prefs.getInt(tsKey);

    if (cached != null && cachedTs != null) {
      final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
      if (age < maxAge.inMilliseconds) {
        // Cache is fresh — store it for fallback
        options.extra['cached_response'] = cached;
      }
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Cache successful GET responses
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200 &&
        response.data != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cacheKey = _prefix + response.requestOptions.uri.toString();
        final tsKey = _timestampPrefix + response.requestOptions.uri.toString();
        final data = response.data is String
            ? response.data as String
            : jsonEncode(response.data);

        await prefs.setString(cacheKey, data);
        await prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);
      } catch (e) {
        // Cache write failed — not critical
        AppLogger.error('[CACHE] Failed to write cache', e);
      }
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If request failed and we have cached data, return it
    if (err.requestOptions.method.toUpperCase() == 'GET') {
      final cached = err.requestOptions.extra['cached_response'] as String?;
      if (cached != null) {
        AppLogger.info(
          '[CACHE] Returning cached data for ${err.requestOptions.uri}',
        );

        try {
          final data = jsonDecode(cached);
          return handler.resolve(
            Response(
              requestOptions: err.requestOptions,
              data: data,
              statusCode: 200,
              extra: {'from_cache': true},
            ),
          );
        } catch (e) {
          // Cache parse failed
        }
      }
    }

    return handler.next(err);
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
    final tsKeys = prefs.getKeys().where((k) => k.startsWith(_timestampPrefix));
    for (final key in tsKeys) {
      await prefs.remove(key);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// BACKEND HEALTH CHECK
// ═══════════════════════════════════════════════════════════════

/// Checks if the backend is reachable.
/// Returns true if healthy, false otherwise.
/// Uses a bare Dio instance (no interceptors) to avoid retries/logging noise.
Future<bool> checkBackendHealth() async {
  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
    final response = await dio.get(
      '/health',
      options: Options(receiveTimeout: const Duration(seconds: 3)),
    );
    return response.statusCode == 200;
  } catch (_) {
    // Silently fail — the UI will show the offline screen
    return false;
  }
}
