import 'package:flutter/foundation.dart';

/// API Configuration Constants
class ApiConstants { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  ApiConstants._();

  /// Base URL of the FastAPI backend.
  ///
  /// Defaults to the address that actually reaches the development machine
  /// from the running platform:
  ///   * Android emulator → `10.0.2.2` (the emulator's alias for the host)
  ///   * everything else  → `localhost`
  ///
  /// A USB phone reaches the host through `localhost` once the reverse tunnel
  /// is set up (`adb reverse tcp:8000 tcp:8000`); if that is missing, the first
  /// request transparently retries `10.0.2.2` and keeps the host that works.
  ///
  /// Override at run time when neither default applies (e.g. a phone on the
  /// same Wi-Fi as the PC):
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.0.110:8000
  static String baseUrl = _override.isNotEmpty ? _override : _platformDefault;

  static const String _override = String.fromEnvironment('API_BASE_URL');
  static const String _localhost = 'http://localhost:8000';
  static const String _emulator = 'http://10.0.2.2:8000';

  static String get _platformDefault =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? _emulator
      : _localhost;

  /// True when the URL came from `--dart-define`; explicit config is never
  /// second-guessed at runtime.
  static bool get isOverridden => _override.isNotEmpty;

  /// Hosts to probe once at startup on Android, in order of preference.
  ///
  /// Empty when the URL was supplied explicitly or the platform has a single
  /// correct host (desktop, web, iOS).
  static List<String> get androidHostCandidates =>
      !isOverridden &&
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android
      ? const [_emulator, _localhost]
      : const [];

  /// The other Android host alias to try when [baseUrl] is unreachable, or
  /// `null` on platforms where there is nothing to fall back to.
  static String? get fallbackBaseUrl {
    if (isOverridden ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    if (baseUrl == _emulator) return _localhost;
    if (baseUrl == _localhost) return _emulator;
    return null;
  }

  /// Remembers the host that answered so later requests skip the dead one.
  static void useBaseUrl(String url) => baseUrl = url;

  // API Prefix
  static const String apiPrefix = '/api/v1';

  // Auth Endpoints
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String forgotPassword = '$apiPrefix/auth/forgot-password';
  static const String resetPassword = '$apiPrefix/auth/reset-password';
  static const String refreshToken = '$apiPrefix/auth/refresh';
  static const String profile = '$apiPrefix/auth/profile';

  // Destinations
  static const String destinations = '$apiPrefix/destinations';

  // Hotels
  static const String hotels = '$apiPrefix/hotels';

  // Transports
  static const String transports = '$apiPrefix/transports';

  // Guides
  static const String guides = '$apiPrefix/guides';

  // Bookings
  static const String bookings = '$apiPrefix/bookings';

  // Payments
  static const String payments = '$apiPrefix/payments';

  // Packages
  static const String packages = '$apiPrefix/packages';
  static const String userPackages = '$apiPrefix/user-packages';

  // Admin
  static const String adminUsers = '$apiPrefix/admin/users';
  static const String adminBookings = '$apiPrefix/admin/bookings';
  static const String adminPayments = '$apiPrefix/admin/payments';
  static const String adminListings = '$apiPrefix/admin/listings';
  static const String adminPackages = '$apiPrefix/admin/packages';
  static const String adminStats = '$apiPrefix/admin/stats';
}
